extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("spawn")
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		call_deferred("change_era_scene")

func change_era_scene():
		match Globals.era:
			"Modern":
				get_tree().change_scene_to_file("res://Scenes/medieval.tscn")
			"Medieval":
				print("Stone Age scene not built yet")
