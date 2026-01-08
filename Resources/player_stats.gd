extends Resource
class_name player_era

@export_enum("Modern", "Medieval", "StoneAge", "Monke") var era: String = "Modern"

@export_group("Movement")
@export var move_speed: float = 200.0
@export var acceleration: float = 10
@export var friction: float = 15

@export_group("Health")
@export var max_health: int = 5

@export_group("Projectile Mechanics")
@export var projectile_damage = 1
@export var projectile_speed: float = 600.0
@export var projectile_knockback_force: float = 300.0
@export var projectile_inaccuracy: float = 10.0
@export var fire_delay: float = 0.25
@export var bullet_scene: PackedScene
@export var recoil_strength: float = 900.0
@export var magazine_size = 6
@export var pierce_value = 1
## Base reload length is 2 seconds, so change this value if you want reload to be longer
@export var reload_speed = 1.0 

@export_group("Visuals")
@export var weapon: Texture2D
@export var sprite: Texture2D

@export_group("Ability Stats")
@export var ability_cooldown := 5.0
@export var ability_icon: Texture2D
