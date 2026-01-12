extends Enemy
class_name Medieval_Boss

enum State { CHASE, CHARGE, DASH }

@export_group("Dash Settings")
@export var dash_speed: float = 600.0
@export var charge_time: float = 1.2
@export var dash_cooldown: float = 4.0
@export var max_dash_duration: float = 3.0

var current_state: State = State.CHASE
var dash_direction: Vector2 = Vector2.ZERO
var dash_cooldown_timer: float = 2.0 
var dash_duration_timer: float = 0.0
@onready var marker_2d: Marker2D = $Marker2D

@onready var boss_health_bar: CanvasLayer = $BossHealthBar as Boss_health_bar_ui

@onready var telegraph_line: Line2D = $TelegraphLine 

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if era_data:
		apply_enemy_data(era_data)
	else:
		health = max_health
	
	if sprite.material:
		sprite.material = sprite.material.duplicate()
	
	drop_in(randf_range(0, 0.5))
	can_move = false
	
	boss_health_bar.set_max_health(health)
	boss_health_bar.visible = false
	
	telegraph_line.width = 40.0 
	telegraph_line.default_color = Color(1, 0, 0, 0.4) 
	telegraph_line.visible = false
	telegraph_line.points = [Vector2.ZERO, Vector2.ZERO]
	Dialogic.signal_event.connect(DialogicSignal)
	
	await get_tree().create_timer(1.5).timeout
	run_dialogue("MedievalBoss")

func run_dialogue(dialogue):
	var layout = Dialogic.start(dialogue)
	layout.register_character(load("uid://cfchxitqn0s5j"), marker_2d)

func DialogicSignal(arg: String):
	match arg:
		"in_cutscene":
			can_move = false
		"end_cutscene":
			await get_tree().create_timer(0.5).timeout
			can_move = true
			boss_health_bar.visible = true

func _physics_process(delta: float) -> void:
	if in_cutscene or is_dead or !can_move:
		velocity = Vector2.ZERO
		return
		
	if player_in_range != null and attack_timer <= 0.0:
		var dir = (player_in_range.global_position - global_position).normalized()
		player_in_range.apply_hit(dir, contact_damage, contact_knockback)
		attack_timer = attack_cooldown
	
	attack_timer -= delta
	
	match current_state:
		State.CHASE:
			handle_chase(delta)
		State.CHARGE:
			handle_charge(delta)
		State.DASH:
			handle_dash(delta)

	move_and_slide()


func handle_chase(delta: float):
	dash_cooldown_timer -= delta
	
	if player != null:
		
		enemy_animation_player.play("walk")
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * move_speed
		sprite.flip_h = velocity.x < 0
		
		if dash_cooldown_timer <= 0:
			start_charge()
	else:
		velocity = Vector2.ZERO

func start_charge():
	current_state = State.CHARGE
	velocity = Vector2.ZERO
	telegraph_line.visible = true
	
	var tween = create_tween()
	telegraph_line.set_point_position(1, Vector2.ZERO)
	tween.tween_method(func(pos): telegraph_line.set_point_position(1, pos), 
		Vector2.ZERO, Vector2(500, 0), charge_time)
	
	await get_tree().create_timer(charge_time).timeout
	start_dash()

func handle_charge(_delta: float):
	if player:
		var dir = (player.global_position - global_position).normalized()
		telegraph_line.rotation = dir.angle()
		dash_direction = dir 

func start_dash():
	telegraph_line.visible = false
	current_state = State.DASH
	velocity = dash_direction * dash_speed
	dash_duration_timer = max_dash_duration
	SoundManager.play_GoldenKnightDash()

func handle_dash(delta: float):
	velocity = dash_direction * dash_speed
	dash_duration_timer -= delta
	
	if dash_duration_timer <= 0.0 || is_on_wall() || is_on_floor() || is_on_ceiling():
		if is_on_wall() || is_on_floor() || is_on_ceiling():
			SoundManager.play_GoldenKnightHitWall()
			Globals.camera.shake(0.4, 15, 20)
		finish_dash()

func finish_dash():
	current_state = State.CHASE
	dash_cooldown_timer = dash_cooldown
	velocity = Vector2.ZERO 


func apply_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	super.apply_hit(hit_dir, damage, force)
	boss_health_bar.update_health(health)

func drop_in(delay: float = 0):
	in_cutscene = true
	
	var shadow_base_scale = shadow.scale
	
	sprite.position.y = -2800
	sprite.modulate.a = 0 
	shadow.scale = shadow_base_scale * 0.2
	shadow.modulate.a = 0.1
	shadow.pivot_offset = shadow.size / 2
	
	call_deferred("set_collision_layer_value", 1, false)
	call_deferred("set_collision_mask_value", 1, false)
	collision_shape_2d.set_deferred("disabled", true)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "position:y", 8.333, 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(delay)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.2).set_delay(delay)
	
	tween.tween_property(sprite, "scale", Vector2(0.7, 0.7), 0.4).set_delay(delay)
	
	tween.tween_property(shadow, "scale", shadow_base_scale, 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(delay)
	tween.tween_property(shadow, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(delay)
	
	await tween.finished
	
	var impact_tween = create_tween()
	impact_tween.tween_property(sprite, "scale", Vector2(1.4, 0.6), 0.1)
	impact_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	await impact_tween.finished
	
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	collision_shape_2d.disabled = false
	in_cutscene = false
