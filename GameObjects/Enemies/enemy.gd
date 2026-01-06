extends CharacterBody2D
class_name Enemy

@export var max_health: int = 3
@export var move_speed: float = 80.0
@export var knockback_resistance: float = 0.2
@export var contact_damage: int = 1
@export var contact_knockback: float = 400.0
@export var attack_cooldown: float = 0.8
var attack_timer: float = 0.0
var health: int
var knockback_velocity: Vector2 = Vector2.ZERO
var player_in_range: Node = null

@export var blast_particles: PackedScene = preload("uid://by5v6txb30nmu")
@export var explosion_particles: PackedScene = preload("uid://61wtmbq585ep")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

const DAMAGE_NUMBERS = preload("uid://dsvh4p886swh6")

func _ready() -> void:
	health = max_health
	
	if sprite.material:
		sprite.material = sprite.material.duplicate()


func _physics_process(delta: float) -> void:
	attack_timer -= delta
	if player_in_range != null and attack_timer <= 0.0:
		var dir = (player_in_range.global_position - global_position).normalized()
		player_in_range.apply_hit(dir, contact_damage, contact_knockback)
		attack_timer = attack_cooldown

	var player = get_tree().get_first_node_in_group("player")

	if player != null:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * move_speed
	else:
		velocity = Vector2.ZERO

	# Apply knockback
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_resistance)

	move_and_slide()


func apply_hit(hit_dir: Vector2, damage: int, force: float) -> void:
	health -= damage
	var damage_text = DAMAGE_NUMBERS.instantiate() as Node2D
	get_tree().current_scene.add_child(damage_text)
	damage_text.global_position = global_position + Vector2(randi_range(-20, 20), randi_range(-90, -100))
	damage_text.start(str(damage))
	
	if health <= 0:
		die()
	else:
		animation_player.play("hitFlash")
		knockback_velocity += hit_dir * force
		
		spawn_particles(blast_particles, self.position, Vector2.ZERO)
		
		

func _on_body_entered(body: Node) -> void:
	if attack_timer > 0.0:
		return

	if body.is_in_group("player"):
		var dir = (body.global_position - global_position).normalized()
		body.apply_hit(dir, contact_damage, contact_knockback)
		attack_timer = attack_cooldown


func _on_area_2d_body_entered(body: Node2D) -> void:
	if attack_timer > 0.0:
		return

	if body.is_in_group("player"):
		player_in_range = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func die():
	spawn_particles(explosion_particles, self.position, Vector2.ZERO)
	queue_free()

func spawn_particles(SCENE: PackedScene, pos: Vector2, normal: Vector2) -> void:
	var instance = SCENE.instantiate()
	get_tree().get_current_scene().add_child(instance)
	instance.global_position = pos
	instance.rotation = normal.angle()
