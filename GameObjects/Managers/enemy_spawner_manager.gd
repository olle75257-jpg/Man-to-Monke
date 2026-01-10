extends Node

const SPAWN_RADIUS = 500

@export var basic_enemy_scene: PackedScene 
@export var boss_enemy_scene: PackedScene 
@export var enemy_types: Array[PackedScene]

var enemy_count = 0
var spawn_interval = 0.5
var wave = 1

var enemy_table = WeightedTable.new()

func _ready() -> void:
	print("Current era: ", Globals.era)
	Signals.enemy_died.connect(decrease_enemy_count)
	spawn_next_wave()

signal summon_portal

func decrease_enemy_count():
	enemy_count -= 1
	check_enemy_count()

func check_enemy_count():
	#print("Enemy_count: ", enemy_count)
	
	if enemy_count == 0:
		wave += 1
		if wave == 7:
			Globals.finished_era = true
			summon_portal.emit()
		else:
			print("No enemies remaining, beginning next wave")
			spawn_next_wave()

func spawn_next_wave():
	#print("Current era", Globals.era)
	match Globals.era:
		"Modern":
			match wave:
				1:
					enemy_count = 5 # 5
					enemy_table.add_item(0, 15)
				2:
					enemy_count = 5
				3:
					enemy_count = 10
				4, 5:
					enemy_count = 15
				6:
					enemy_count = 1
					enemy_table.remove_item(0)
					enemy_table.add_item(1, 15)
		"Medieval":
			match wave:
				1:
					enemy_count = 12 #12
					spawn_interval = 1.0
					enemy_table.add_item(0, 15)
				2:
					enemy_count = 12
					spawn_interval = 0.01
				3:
					enemy_count = 12
					spawn_interval = 2
				4, 5:
					enemy_count = 12
					spawn_interval = 1.5
				6:
					enemy_count = 1
					enemy_table.remove_item(0)
					enemy_table.add_item(1, 15)
		"StoneAge":
			match wave:
				1:
					enemy_count = 5 # 5
					enemy_table.add_item(0, 15)
				2:
					enemy_count = 5
				3:
					enemy_count = 10
				4, 5:
					enemy_count = 15
				6:
					enemy_count = 1
					enemy_table.remove_item(0)
					enemy_table.add_item(1, 15)
		_:
			match wave:
				1:
					enemy_count = 5
					enemy_table.add_item(0, 15) 
				2:
					enemy_count = 5
				3:
					enemy_count = 10
				4, 5:
					enemy_count = 15
	spawn_enemies(enemy_count, spawn_interval)



func spawn_enemies(enemy_amount: int, spawn_interval: float):
	var enemy_type_index = enemy_table.pick_item()
	
	for i in range(enemy_amount):
		var player = get_tree().get_first_node_in_group("player") as Node2D
		if player == null:
			return
		
		var enemy_scene = basic_enemy_scene
		if enemy_type_index == 1:
			if boss_enemy_scene == null:
				return
			enemy_scene = boss_enemy_scene
			
			
		var enemy = enemy_scene.instantiate() as Node2D
			
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child.call_deferred(enemy)
		enemy.global_position = get_spawn_position()
		await get_tree().create_timer(0.5).timeout


func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		print("what")
		return Vector2.ZERO
	
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20
		
		var query_paramaters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1 << 3)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_paramaters)
		
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position
