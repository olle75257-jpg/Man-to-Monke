extends CanvasLayer


func _on_replay_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://UserInterface/bootsplash.tscn")
