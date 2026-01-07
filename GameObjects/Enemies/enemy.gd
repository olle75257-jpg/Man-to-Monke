extends CharacterBody2D
class_name Enemy

@export var era_data: enemy_type 

@export_group("Stats")
@export var max_health: int = 3
@export var move_speed: float = 80.0
@export var knockback_resistance: float = 0.2
@export var contact_damage: int = 1
@export var contact_knockback: float = 400.0
@export var attack_cooldown: float = 0.8
var attack_timer: float = 0.0
var health: int
var knockback_velocity: Vector2 = Vector2.ZERO
var player_in_range: Node = null

@export var blast_particles: PackedScene = preload("uid://by5v6txb30nmu")
@export var explosion_particles: PackedScene = preload("uid://61wtmbq585ep")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

const DAMAGE_NUMBERS = preload("uid://dsvh4p886swh6")
var in_cutscene = false

func _ready() -> void:
	if era_data:
		apply_enemy_data(era_data)
	else:
		health = max_health
	
	if sprite.material:
		sprite.material = sprite.material.duplicate()
	
	drop_in(randf_range(0, 0.5))

func apply_enemy_data(data: enemy_type):
	max_health = data.max_health
	health = max_health 
	
	move_speed = data.move_speed
	knockback_resistance = data.knockback_resistance
	
	contact_damage = data.contact_damage
	contact_knockback = data.contact_knockback
	attack_cooldown = data.attack_cooldown
	
	if data.sprite:
		sprite.texture = data.sprite
		
	#print("Enemy initialized as: ", data.era)

func _physics_process(delta: float) -> void:
	if in_cutscene:
		velocity = Vector2.ZERO
		#move_and_slide()
		return
	
	attack_timer -= delta
	if player_in_range != null and attack_timer <= 0.0:
		var dir = (player_in_range.global_position - global_position).normalized()
		player_in_range.apply_hit(dir, contact_damage, contact_knockback)
		attack_timer = attack_cooldown

	var player = get_tree().get_first_node_in_group("player")

	if player != null:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * move_speed
	else:
		velocity = Vector2.ZERO

	# Apply knockback
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_resistance)

	move_and_slide()
	
@onready var shadow: TextureRect = $Shadow
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func drop_in(delay: float = 0):
	in_cutscene = true
	
	var shadow_base_scale = shadow.scale
	
	sprite.position.y = -2800
	sprite.modulate.a = 0 
	shadow.scale = shadow_base_scale * 0.2
	shadow.modulate.a = 0.1
	shadow.pivot_offset = shadow.size / 2
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	collision_shape_2d.disabled = true
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "position:y", 0, 2.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(delay)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.2).set_delay(delay)
	
	tween.tween_property(sprite, "scale", Vector2(0.7, 1.4), 0.4).set_delay(delay)
	
	tween.tween_property(shadow, "scale", shadow_base_scale, 2.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(delay)
	tween.tween_property(shadow, "modulate:a", 1.0, 2.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(delay)
	
	await tween.finished
	
	var impact_tween = create_tween()
	impact_tween.tween_property(sprite, "scale", Vector2(1.4, 0.6), 0.1)
	impact_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	await impact_tween.finished
	
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	collision_shape_2d.disabled = false
	in_cutscene = false


func apply_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	health -= damage
	var damage_text = DAMAGE_NUMBERS.instantiate() as Node2D
	get_tree().current_scene.add_child(damage_text)
	damage_text.global_position = global_position + Vector2(randi_range(-20, 20), randi_range(-90, -100))
	damage_text.start(str(damage))
	
	if health <= 0:
		Globals.kills += 1
		Signals.kills_changed.emit()
		die()
	else:
		animation_player.play("hitFlash")
		knockback_velocity += hit_dir * force
		
		spawn_particles(blast_particles, self.position, Vector2.ZERO)
		
		

func _on_body_entered(body: Node) -> void:
	if attack_timer > 0.0:
		return

	if body.is_in_group("player"):
		var dir = (body.global_position - global_position).normalized()
		body.apply_hit(dir, contact_damage, contact_knockback)
		attack_timer = attack_cooldown


func _on_area_2d_body_entered(body: Node2D) -> void:
	if attack_timer > 0.0:
		return

	if body.is_in_group("player"):
		player_in_range = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func die():
	spawn_particles(explosion_particles, self.position, Vector2.ZERO)
	queue_free()

func spawn_particles(SCENE: PackedScene, pos: Vector2, normal: Vector2) -> void:
	var instance = SCENE.instantiate()
	get_tree().get_current_scene().add_child(instance)
	instance.global_position = pos
	instance.rotation = normal.angle()
