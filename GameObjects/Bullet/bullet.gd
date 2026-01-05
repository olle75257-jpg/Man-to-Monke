extends Area2D

@export var speed: float = 600.0
@export var damage: int = 1
@export var knockback_force: float = 300.0

var direction: Vector2 = Vector2.ZERO
@export var spread_degrees: float = 10.0

func _ready() -> void:
	direction = (get_global_mouse_position() - global_position).normalized()
	var random_angle = randf_range(-spread_degrees, spread_degrees)
	direction = direction.rotated(deg_to_rad(random_angle))
	
	rotation = direction.angle()
	

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	#look_at(global_position + direction)


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("apply_hit"):
		body.apply_hit(direction, damage, knockback_force)
	queue_free()
