extends Control

@onready var player: CharacterBody2D = %Player 
@onready var label: Label = $HBoxContainer/Label
@onready var projectile_icon: TextureRect = $HBoxContainer/ProjectileIcon

@export var sprite: Texture2D

func _ready() -> void:
	label.text = str(player.ammo_in_mag) + "/" + str(player.magazine_size)
	projectile_icon.texture = sprite
	

func _on_player_ammo_changed() -> void:
	label.text = str(player.ammo_in_mag) + "/" + str(player.magazine_size)
