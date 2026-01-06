extends Control
@onready var player: CharacterBody2D = %Player
@onready var label: Label = $Label

func _ready() -> void:
	if player:
		label.text = str(player.health) + "/" + str(player.max_health) + " HP"


func _on_player_health_changed() -> void:
	if player == null:
		return
	
	label.text = str(player.health) + "/" + str(player.max_health) + " HP"
