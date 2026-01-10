extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("in")
	await animation_player.animation_finished
	match Globals.era:
		"Modern":
			get_tree().change_scene_to_file("res://Scenes/modern.tscn")
		"Medieval":
			get_tree().change_scene_to_file("res://Scenes/medieval.tscn")
		"StoneAge":
			get_tree().change_scene_to_file("res://Scenes/stone_age.tscn")
			
