extends Control

@onready var label: Label = $HBoxContainer/Label

func _ready() -> void:
	label.text = "Kills: " + str(Globals.kills)
	Signals.kills_changed.connect(update_text)

func update_text():
	label.text = "Kills: " + str(Globals.kills)
