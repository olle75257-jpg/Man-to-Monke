extends Enemy

@onready var boss_health_bar: CanvasLayer = $BossHealthBar


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if era_data:
		apply_enemy_data(era_data)
	else:
		health = max_health
	
	if sprite.material:
		sprite.material = sprite.material.duplicate()
	
	drop_in(randf_range(0, 0.5))
