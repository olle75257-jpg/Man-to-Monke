extends Area2D
class_name Projecitle

@export var speed: float = 600.0
@export var damage: int = 1
@export var knockback_force: float = 300.0

var direction: Vector2 = Vector2.ZERO
@export var spread_degrees: float = 10.0
var pierce_value = 1

func _ready() -> void:
	direction = (get_global_mouse_position() - global_position).normalized()
	var random_angle = randf_range(-spread_degrees, spread_degrees)
	direction = direction.rotated(deg_to_rad(random_angle))
	
	rotation = direction.angle()
	

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	#look_at(global_position + direction)


func _on_body_entered(body: Node) -> void:
	if body is Enemy and body.has_method("apply_hit"):
		if pierce_value > 0:
			pierce_value -= 1
			body.apply_hit(direction, damage, knockback_force)
			if pierce_value == 0:
				queue_free()
	if body is StaticBody2D:
		queue_free()
