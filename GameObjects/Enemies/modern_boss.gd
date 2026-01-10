extends Enemy

@onready var boss_health_bar: Boss_health_bar_ui = $BossHealthBar
@onready var speech_bubble_pos: Marker2D = %SpeechBubblePos


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if era_data:
		apply_enemy_data(era_data)
	else:
		health = max_health
	
	if sprite.material:
		sprite.material = sprite.material.duplicate()
	
	boss_health_bar.visible = false
	boss_health_bar.set_max_health(health)
	
	drop_in(randf_range(0, 0.5))
	Dialogic.signal_event.connect(DialogicSignal)
	
	await get_tree().create_timer(1.5).timeout
	run_dialogue("ModernBoss")

func run_dialogue(dialogue):
	var layout = Dialogic.start(dialogue)
	layout.register_character(load("uid://xtn2uc1up4tn"), speech_bubble_pos)

func DialogicSignal(arg: String):
	match arg:
		"in_cutscene":
			can_move = false
		"end_cutscene":
			await get_tree().create_timer(0.5).timeout
			can_move = true
			boss_health_bar.visible = true

func apply_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	super.apply_hit(hit_dir, damage, force)
	boss_health_bar.update_health(health)

func drop_in(delay: float = 0):
	in_cutscene = true
	
	var shadow_base_scale = shadow.scale
	
	sprite.position.y = -2800
	sprite.modulate.a = 0 
	shadow.scale = shadow_base_scale * 0.2
	shadow.modulate.a = 0.1
	shadow.pivot_offset = shadow.size / 2
	
	call_deferred("set_collision_layer_value", 1, false)
	call_deferred("set_collision_mask_value", 1, false)
	collision_shape_2d.set_deferred("disabled", true)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "position:y", 8.333, 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(delay)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.2).set_delay(delay)
	
	tween.tween_property(sprite, "scale", Vector2(0.7, 0.7), 0.4).set_delay(delay)
	
	tween.tween_property(shadow, "scale", shadow_base_scale, 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(delay)
	tween.tween_property(shadow, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(delay)
	
	await tween.finished
	
	var impact_tween = create_tween()
	impact_tween.tween_property(sprite, "scale", Vector2(1.4, 0.6), 0.1)
	impact_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	await impact_tween.finished
	
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	collision_shape_2d.disabled = false
	in_cutscene = false
