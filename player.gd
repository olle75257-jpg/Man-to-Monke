extends CharacterBody2D
class_name Player

@export var era_data: player_era

@export_group("Player_stats")
@export var move_speed: float = 200.0
@export var acceleration: float = 10
@export var friction: float = 15

@export var max_health: int = 5
var health: int
signal health_changed

@export var fire_delay: float = 0.25
var fire_timer: float = 0.0
@export var bullet_scene: PackedScene
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_resistance: float = 0.25
@export var recoil_strength: float = 900.0

@onready var reload_animation: Node2D = $reloadAnimation
@export var magazine_size = 6
var ammo_in_mag = 6
const reload_length = 2.0
var reload_speed = 1.0
var is_reloading: bool = false
signal ammo_changed

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var gun: Sprite2D = $Gun
@onready var marker_2d: Marker2D = $Gun/Marker2D
@onready var sprite: Sprite2D = $Sprite

@export var explosion_particles: PackedScene = preload("uid://61wtmbq585ep")

@onready var camera: Camera2D = %Camera2D
@export_group("Camera Look Ahead")
@export var look_ahead_factor: float = 0.2 
@export var max_offset: float = 150.0

func _ready() -> void:
	explosion_particles = preload("uid://61wtmbq585ep")
	if era_data:
		apply_era_stats(era_data)
	else:
		ammo_in_mag = magazine_size
		health = max_health

func apply_era_stats(data: player_era):
	#Movement 
	move_speed = data.move_speed
	acceleration = data.acceleration
	friction = data.friction
	
	#Health 
	max_health = data.max_health
	health = max_health 
	
	#Projectile/Weapon Stats
	fire_delay = data.fire_delay
	bullet_scene = data.bullet_scene
	recoil_strength = data.recoil_strength
	magazine_size = data.magazine_size
	ammo_in_mag = magazine_size 
	reload_speed = data.reload_speed
	
	#Visuals 
	if data.weapon:
		gun.texture = data.weapon
	if data.sprite:
		sprite.texture = data.sprite
	
	health_changed.emit.call_deferred()
	ammo_changed.emit.call_deferred()
	
	print("Swapped to Era: ", data.era)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		reload()

func _process(delta: float) -> void:
	update_camera_offset()

func update_camera_offset():
	var mouse_pos = get_local_mouse_position()
	var target_offset = mouse_pos * look_ahead_factor
	
	target_offset = target_offset.limit_length(max_offset)
	camera.offset = camera.offset.lerp(target_offset, 0.1)

func _physics_process(delta: float) -> void:
	# Movement
	var mouse_pos = get_global_mouse_position()
	
	gun.look_at(get_global_mouse_position())
	if mouse_pos.x > global_position.x:
		# Mouse is to the right
		sprite.scale.x = abs(sprite.scale.x)
		gun.scale.x = abs(gun.scale.x)
		gun.scale.y = abs(gun.scale.y)
		#character_shadow.scale.x = abs(character_shadow.scale.x)
	else:
		# Mouse is to the left
		gun.scale.y = -abs(gun.scale.y)
		sprite.scale.x = -abs(sprite.scale.x)
		#character_shadow.scale.x = -abs(character_shadow.scale.x)
	
	var input_vector := Vector2.ZERO

	input_vector.x = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)

	input_vector.y = (
		Input.get_action_strength("move_down")
		- Input.get_action_strength("move_up")
	)

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.lerp(input_vector * move_speed, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
	
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_resistance)	
	move_and_slide()

	# Shooting cooldown
	fire_timer -= delta

	if Input.is_action_pressed("shoot") and fire_timer <= 0.0 && (ammo_in_mag > 0):
		shoot()
		var recoil_dir = (global_position - get_global_mouse_position()).normalized()
		velocity += recoil_dir * recoil_strength
		fire_timer = fire_delay
		if ammo_in_mag == 0:
			reload()


func shoot() -> void:
	if bullet_scene == null:
		return
	
	Globals.camera.shake(0.25, 10, 15)
	ammo_in_mag -= 1
	ammo_changed.emit()
	SoundManager.play_gunShot()
	var bullet = bullet_scene.instantiate() as Projecitle
	
	bullet.global_position = marker_2d.global_position
	bullet.damage = era_data.projectile_damage
	bullet.speed = era_data.projectile_speed
	bullet.spread_degrees = era_data.projectile_inaccuracy
	bullet.knockback_force = era_data.projectile_knockback_force
	
	get_parent().add_child(bullet)
	#var mouse_pos = get_global_mouse_position()
	#bullet.direction = (mouse_pos - global_position).normalized()


func apply_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	Globals.camera.shake(0.25, 25, 15)
	spawn_particles(explosion_particles, self.position, Vector2.ZERO)
	health -= damage
	health_changed.emit()
	knockback_velocity += hit_dir * force
	disable_hitbox()
	
	if health <= 0:
		die()

func disable_hitbox():
	collision_shape_2d.disabled = true
	await get_tree().create_timer(0.8).timeout
	collision_shape_2d.disabled = false

func reload():
	if is_reloading: 
		return
	SoundManager.play_reload()
	is_reloading = true
	
	reload_animation.animation_player.speed_scale = reload_speed
	reload_animation.play_reload()
	await get_tree().create_timer(reload_length / reload_speed).timeout
	ammo_in_mag = magazine_size
	ammo_changed.emit()
	is_reloading = false

func die() -> void:
	print("Player died")
	queue_free()

func spawn_particles(SCENE: PackedScene, pos: Vector2, normal: Vector2) -> void:
	var instance = SCENE.instantiate()
	get_tree().get_current_scene().add_child(instance)
	instance.global_position = pos
	instance.rotation = normal.angle()
