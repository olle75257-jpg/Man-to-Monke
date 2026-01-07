extends Node2D

@onready var camera = %Camera2D
@onready var portal_scene = preload("uid://cikxjss50ywqa")
@onready var portal_spawn_position: Marker2D = $PortalSpawnPosition
@onready var animation_player: AnimationPlayer = $TransitionAnimationPlayer

var portal_spawned: bool = false

func _ready() -> void:
	animation_player.play("transition_iris")
	Globals.era = "Modern"
	portal_spawned = false
	Globals.kills = 0
	Globals.camera = camera
	Signals.kills_changed.connect(summon_portal)

func summon_portal():
	if Globals.kills >= 5 && !portal_spawned:
		portal_spawned = true
		var portal = portal_scene.instantiate() as Node2D
		portal.global_position = portal_spawn_position.global_position
		add_child.call_deferred(portal)
