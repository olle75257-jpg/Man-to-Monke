extends Enemy
class_name Boss

@onready var boss_hp: ProgressBar = $CanvasLayer/BossHP

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if era_data:
		apply_enemy_data(era_data)
	else:
		health = max_health
	
	if sprite.material:
		sprite.material = sprite.material.duplicate()
	
	drop_in(randf_range(0, 0.5))
	boss_hp.max_value = health
	boss_hp.value = health 

func apply_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	if is_dead:
		return
	
	var is_crit: bool = randf() <= 0.20
	var final_damage: int = damage
	
	if is_crit:
		final_damage = damage * 2
	
	health -= final_damage
	boss_hp.value = health 
	var damage_text = DAMAGE_NUMBERS.instantiate() as Node2D
	get_tree().current_scene.add_child(damage_text)
	damage_text.global_position = global_position + Vector2(randi_range(-20, 20), randi_range(-90, -100))
	var text_to_show = str(final_damage)
	if is_crit:
		text_to_show += "!"
		damage_text.font_color = Color(1.0, 0.68, 0.0, 1.0)
	
	damage_text.start(text_to_show)
	SoundManager.play_enemyDamage()
	Globals.camera.shake(0.25, 10, 15)
	
	if health <= 0:
		Globals.kills += 1
		Signals.kills_changed.emit()
		die()
	else:
		animation_player.play("hitFlash")
		knockback_velocity += hit_dir * force
		
		spawn_particles(blast_particles, self.position, Vector2.ZERO)
