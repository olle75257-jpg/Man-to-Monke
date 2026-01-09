extends Area2D

@export var spread_degrees: float = 10.0

@export_group("Horizontal Movement")
@export var initial_speed: float = 600.0
@export var friction: float = 600.0

@export_group("Vertical Arc (Fake Z)")
@export var arc_gravity: float = 1500.0
@export var jump_force: float = -600.0 

var velocity: Vector2 = Vector2.ZERO
var z_velocity: float = 0.0 
var height: float = 0.0     
var is_on_ground: bool = false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var sprite: Sprite2D = $Sprite2D 
@export var grenade_explosion_tscn: PackedScene = preload("uid://df4gg80oh3mtf")

func _ready() -> void:
	set_collision_mask_value(1, true)
	collision_shape_2d.disabled = true
	
	jump_force = -(initial_speed * 1.0)
	
	var dir = (get_global_mouse_position() - global_position).normalized()
	var random_angle = randf_range(-spread_degrees, spread_degrees)
	velocity = dir.rotated(deg_to_rad(random_angle)) * initial_speed
	
	z_velocity = jump_force
	

func _physics_process(delta: float) -> void:
	if is_on_ground:
		return
 
	rotation += velocity.angle() * delta * 2
	var current_speed = velocity.length()
	current_speed = max(0, current_speed - friction * delta)
	velocity = velocity.normalized() * current_speed
	
	position += velocity * delta
	
	z_velocity += arc_gravity * delta
	height += z_velocity * delta
	
	if sprite:
		sprite.position = Vector2(0, height).rotated(-rotation)
	
	if height >= 0:
		height = 0
		sprite.position.y = 0
		land()

func land():
	if velocity.length() > 100:
		z_velocity = jump_force * 0.4 
		velocity *= 0.6               
	else:
		is_on_ground = true
		explode()

func explode():
	SoundManager.play_grenadeExplode()
	if Globals.camera:
		Globals.camera.shake(0.3, 20, 15)
	spawn_particles(grenade_explosion_tscn, self.position, Vector2.ZERO)
	collision_shape_2d.disabled = false
	
	await get_tree().create_timer(0.3).timeout
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		body.apply_hit( (body.global_position - global_position).normalized() , 100, 3000)

func spawn_particles(SCENE: PackedScene, pos: Vector2, normal: Vector2) -> void:
	var instance = SCENE.instantiate()
	get_tree().get_current_scene().add_child(instance)
	instance.global_position = pos
	instance.rotation = normal.angle()
