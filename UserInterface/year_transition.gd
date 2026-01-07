extends CanvasLayer

@onready var year_label: Label = $YearLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var year: int = 2026
func _ready() -> void:
	Globals.era = "Medieval"
	animation_player.play("in")
	
	match Globals.era:
		"Modern":
			year = 2026
			update_year_display(year)
		"Medieval":
			year = 2026
			await get_tree().create_timer(1.0).timeout
			change_year_to(1450)
		"StoneAge":
			year = 1450
			await get_tree().create_timer(1.0).timeout
			change_year_to(5000)
	
	await get_tree().create_timer(2.0).timeout
	

func change_year_to(target_year: int):
	var tween = create_tween()
	
	tween.tween_method(update_year_display, year, target_year, 4)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	year = target_year
	
	await tween.finished
	animation_player.play_backwards("in")
	await animation_player.animation_finished
	change_era_scene()

func update_year_display(value: int):
	var suffix = " AD"
	if Globals.era == "StoneAge":
		suffix = " BC"
	
	year_label.text = "Year:   " + str(value) + suffix

func change_era_scene():
		match Globals.era:
			"Modern":
				pass
			"Medieval":
				get_tree().change_scene_to_file("res://Scenes/medieval.tscn")
			"StoneAge":
				get_tree().change_scene_to_file("uid://c4h4y5ns058j3")
