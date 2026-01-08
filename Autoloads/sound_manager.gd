extends Node

@onready var gun_shot: AudioStreamPlayer = $Game/Gun/GunShot
@onready var reload: AudioStreamPlayer = $Game/Gun/Reload
@onready var shockwave_roar: AudioStreamPlayer = $Game/Shockwave/ShockwaveRoar

func play_gunShot():
	gun_shot.play()

func play_reload():
	reload.play()

func play_ShockwaveRoar():
	shockwave_roar.play()
