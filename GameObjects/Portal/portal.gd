extends Area2D
@onready var portal: Area2D = $"."

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_game: AnimationPlayer = $"../TransitionAnimationPlayer"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var dialogue_interacted: bool = false

func _ready() -> void:
	collision_shape_2d.disabled = true
	animation_player.play("spawn")
	Dialogic.signal_event.connect(DialogicSignal)
	
func DialogicSignal(arg: String):
	match arg:
		"allow_portal":
			dialogue_interacted = true
			collision_shape_2d.disabled = false
			

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("idle")

var player_position: Node2D
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_position = Node2D.new()
		get_tree().current_scene.add_child(player_position)
		player_position.global_position = body.global_position
		if !dialogue_interacted:
			var layout = Dialogic.start("EndModern")
			layout.register_character(load("uid://bwnmd4im5nn5y"), portal)
			layout.register_character(load("uid://ducy0qg7xwt3r"), player_position)
		elif dialogue_interacted:
			animation_player_game.play_backwards("transition_iris")
			await get_tree().create_timer(1.0).timeout
			call_deferred("change_era_scene")
		

func change_era_scene():
		get_tree().change_scene_to_file("res://UserInterface/year_transition.tscn")
		
