extends Node2D

@onready var camera = %Camera2D

func _ready() -> void:
	Globals.camera = camera
