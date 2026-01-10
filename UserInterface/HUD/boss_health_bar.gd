extends CanvasLayer
class_name Boss_health_bar_ui

@onready var boss_hp: ProgressBar = $BossHP

func set_max_health(max_val: int):
	boss_hp.max_value = max_val
	boss_hp.value = max_val

func update_health(current_health: int):
	boss_hp.value = current_health
