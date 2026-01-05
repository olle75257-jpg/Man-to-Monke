extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()

func play_reload():
	animation_player.play("reload_animation")
