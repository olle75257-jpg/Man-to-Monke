extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_game: AnimationPlayer = $"../TransitionAnimationPlayer"

func _ready() -> void:
	animation_player.play("spawn")
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		animation_player_game.play_backwards("transition_iris")
		await get_tree().create_timer(1.0).timeout
		call_deferred("change_era_scene")
		

func change_era_scene():
		get_tree().change_scene_to_file("res://UserInterface/year_transition.tscn")
		
