extends CanvasLayer

@onready var year_label: Label = $YearLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var year: int = 2026
func _ready() -> void:
	animation_player.play("in")
	
	match Globals.era:
		"Default":
			year = 2026
			update_year_display(year)
		"Modern":
			year = 2026
			await get_tree().create_timer(1.0).timeout
			change_year_to(1450)
		"Medieval":
			year = 1450
			update_year_display(year)
	
			await get_tree().create_timer(1.0).timeout
			change_year_to(5000)
		"StoneAge":
			year = 5000
			update_year_display(year)
	
			await get_tree().create_timer(1.0).timeout
			change_year_to(10000000)
			
	
	await get_tree().create_timer(2.0).timeout
	

func change_year_to(target_year: int):
	var tween = create_tween()
	
	tween.tween_method(update_year_display, year, target_year, 4)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	year = target_year
	
	await tween.finished
	if Globals.era == "StoneAge":
		var fade_tween = create_tween()
		
		
		fade_tween.tween_property(year_label, "modulate:a", 0.0, 0.5)
		await fade_tween.finished
		
		
		year_label.text = "Monke"
		
		
		fade_tween = create_tween() 
		fade_tween.tween_property(year_label, "modulate:a", 1.0, 0.8)
		await fade_tween.finished
		
		await get_tree().create_timer(2.0).timeout
	animation_player.play_backwards("in")
	await animation_player.animation_finished
	change_era_scene()

func update_year_display(value: int):
	var suffix = " AD"
	if Globals.era == "Medieval":
		suffix = " BC"
	elif Globals.era == "StoneAge":
		suffix = " BC"
	
	year_label.text = "Year:   " + str(value) + suffix

func change_era_scene():
		match Globals.era:
			"Modern":
				get_tree().change_scene_to_file("res://Scenes/medieval.tscn")
			"Medieval":
				get_tree().change_scene_to_file("uid://c4h4y5ns058j3")
			"StoneAge":
				get_tree().change_scene_to_file("res://Scenes/end_cutscene.tscn")
