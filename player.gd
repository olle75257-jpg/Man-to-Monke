extends CharacterBody2D

@export var move_speed: float = 200.0
@export var max_health: int = 5
var health: int
@export var fire_delay: float = 0.25
var fire_timer: float = 0.0
@export var bullet_scene: PackedScene
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_resistance: float = 0.25



func _ready() -> void:
	health = max_health


func _physics_process(delta: float) -> void:
	# Movement
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

	velocity = input_vector * move_speed
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_resistance)	
	move_and_slide()

	# Shooting cooldown
	fire_timer -= delta

	if Input.is_action_pressed("shoot") and fire_timer <= 0.0:
		shoot()
		fire_timer = fire_delay


func shoot() -> void:
	if bullet_scene == null:
		return
	
	SoundManager.play_gunShot()
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	bullet.global_position = global_position

	var mouse_pos = get_global_mouse_position()
	bullet.direction = (mouse_pos - global_position).normalized()


func apply_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	health -= damage
	knockback_velocity += hit_dir * force

	if health <= 0:
		die()


func die() -> void:
	print("Player died")
	queue_free()
