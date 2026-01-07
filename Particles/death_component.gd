extends Node2D

@export var sprite: Sprite2D
@onready var cpu_particles: CPUParticles2D = $CPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	cpu_particles.texture = sprite.texture


func _on_enemy_enemy_killed() -> void:
	spawn_death_animation()



func spawn_death_animation():
	if owner == null || not owner is Node2D:
		return

	var spawn_position = owner.global_position
	
	var entities = get_tree().get_first_node_in_group("entities_layer")
	get_parent().remove_child(self)
	entities.add_child(self)
	
	global_position = spawn_position
	animation_player.play("default")
	
