extends Node2D

@onready var camera = %Camera2D

func _ready() -> void:
	Globals.kills = 0
	Globals.camera = camera
	
