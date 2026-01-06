extends Resource
class_name enemy_type

@export_enum("Modern", "Medieval", "Caveman", "Monkey") var era: String = "Modern"

@export_group("Enemy Stats")
@export var max_health: int = 3
@export var move_speed: float = 80.0
@export var knockback_resistance: float = 0.2

@export_group("Damage Related")
## Damage done to player:
@export var contact_damage: int = 1
## Knockback against player:
@export var contact_knockback: float = 400.0
@export var attack_cooldown: float = 0.8

@export_group("Visuals")
@export var sprite: Texture2D
