#extends Enemy
#class_name Boss
#
#@onready var boss_hp: ProgressBar = $CanvasLayer/BossHP
#
#func _ready() -> void:
	#player = get_tree().get_first_node_in_group("player")
	#if era_data:
		#apply_enemy_data(era_data)
	#else:
		#health = max_health
	#
	#if sprite.material:
		#sprite.material = sprite.material.duplicate()
	#
	#drop_in(randf_range(0, 0.5))
	#boss_hp.max_value = health
	#boss_hp.value = health 
#
#func _physics_process(delta: float) -> void:
	#if in_cutscene:
		#velocity = Vector2.ZERO
		##move_and_slide()
		#return
	#
	#attack_timer -= delta
	#if player_in_range != null and attack_timer <= 0.0:
		#var dir = (player_in_range.global_position - global_position).normalized()
		#player_in_range.apply_hit(dir, contact_damage, contact_knockback)
		#attack_timer = attack_cooldown
#
#
	#if player != null:
		#enemy_animation_player.play("walk")
		#var dir = (player.global_position - global_position).normalized()
		#velocity = dir * move_speed
		#if velocity.x > 0:
			#sprite.flip_h = false 
		#elif velocity.x < 0:
			#sprite.flip_h = true  
	#else:
		#velocity = Vector2.ZERO
#
	## Apply knockback
	#velocity += knockback_velocity
	#knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_resistance)
#
	#move_and_slide()
#
#func apply_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	#if is_dead:
		#return
	#
	#var is_crit: bool = randf() <= 0.20
	#var final_damage: int = damage
	#
	#if is_crit:
		#final_damage = damage * 2
	#
	#health -= final_damage
	#boss_hp.value = health 
	#var damage_text = DAMAGE_NUMBERS.instantiate() as Node2D
	#get_tree().current_scene.add_child(damage_text)
	#damage_text.global_position = global_position + Vector2(randi_range(-20, 20), randi_range(-90, -100))
	#var text_to_show = str(final_damage)
	#if is_crit:
		#text_to_show += "!"
		#damage_text.font_color = Color(1.0, 0.68, 0.0, 1.0)
	#
	#damage_text.start(text_to_show)
	#SoundManager.play_enemyDamage()
	#Globals.camera.shake(0.25, 10, 15)
	#
	#if health <= 0:
		#Globals.kills += 1
		#Signals.kills_changed.emit()
		#die()
	#else:
		#animation_player.play("hitFlash")
		#knockback_velocity += hit_dir * force
		#
		#spawn_particles(blast_particles, self.position, Vector2.ZERO)

extends Enemy
class_name Boss

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

@onready var boss_hp: ProgressBar = $CanvasLayer/BossHP
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
	boss_hp.max_value = health
	boss_hp.value = health 
	
	telegraph_line.width = 40.0 
	telegraph_line.default_color = Color(1, 0, 0, 0.4) 
	telegraph_line.visible = false
	telegraph_line.points = [Vector2.ZERO, Vector2.ZERO]

func _physics_process(delta: float) -> void:
	if in_cutscene or is_dead:
		velocity = Vector2.ZERO
		return

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
	# SoundManager.play_BossDash()
	push_warning("Need boss dash sfx")

func handle_dash(delta: float):
	velocity = dash_direction * dash_speed
	dash_duration_timer -= delta
	
	if dash_duration_timer <= 0.0 || is_on_wall() || is_on_floor() || is_on_ceiling():
		if is_on_wall() || is_on_floor() || is_on_ceiling():
			Globals.camera.shake(0.4, 15, 20)
		finish_dash()

func finish_dash():
	current_state = State.CHASE
	dash_cooldown_timer = dash_cooldown
	velocity = Vector2.ZERO 


func apply_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	super.apply_hit(hit_dir, damage, force)
	boss_hp.value = health
