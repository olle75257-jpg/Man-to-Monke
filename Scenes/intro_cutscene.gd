extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Globals.era = "Intro"
	SoundManager.play_BGM()
	animation_player.play("IntroCutscene")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/modern.tscn")
