extends Node

@onready var gun_shot: AudioStreamPlayer = $Game/Gun/GunShot
@onready var reload: AudioStreamPlayer = $Game/Gun/Reload

func play_gunShot():
	gun_shot.play()

func play_reload():
	reload.play()
