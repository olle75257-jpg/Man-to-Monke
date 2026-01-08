extends TextureButton

@export var era_data: player_era
@onready var timer: Timer = $Timer
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var time_label: Label = $Time

func _ready() -> void:
	if era_data:
		texture_normal = era_data.ability_icon
		timer.wait_time = era_data.ability_cooldown
	else:
		push_error(" " + str(self) + " does not have Era Data resource")
	
	progress_bar.max_value = timer.wait_time
	set_process(false)

func _process(delta: float) -> void:
	time_label.text = "%3.1f " % timer.time_left
	progress_bar.value = timer.time_left


func _on_timer_timeout() -> void:
	disabled = false
	time_label.text = ""
	set_process(false)


func _on_player_ability_used() -> void:
	timer.start()
	disabled = true
	set_process(true)
