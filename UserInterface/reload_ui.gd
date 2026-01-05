extends Control

@onready var player: CharacterBody2D = %Player 
@onready var label: Label = $HBoxContainer/Label

func _ready() -> void:
	label.text = str(player.ammo_in_mag) + "/" + str(player.magazine_size)
	

func _on_player_ammo_changed() -> void:
	label.text = str(player.ammo_in_mag) + "/" + str(player.magazine_size)
