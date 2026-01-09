extends Node

@onready var gun_shot: AudioStreamPlayer = $Game/Gun/GunShot
@onready var reload: AudioStreamPlayer = $Game/Gun/Reload
@onready var shockwave_roar: AudioStreamPlayer = $Game/Shockwave/ShockwaveRoar
@onready var knight_hit: AudioStreamPlayer = $Game/Era/Medieval/KnightHit
@onready var player_hit_stone_age: AudioStreamPlayer = $Game/PlayerSfx/PlayerHitStoneAge
@onready var rock_reload: AudioStreamPlayer = $Game/Era/StoneAge/RockReload
@onready var business_guy_hit: AudioStreamPlayer = $Game/Era/Modern/BusinessGuyHit

func play_shootProjectile():
	match Globals.era:
		"Modern":
			gun_shot.play()
		"Medieval":
			pass
		"StoneAge":
			pass
		_:
			pass

func play_reload():
	match Globals.era:
		"Modern":
			reload.play()
		"Medieval":
			pass
		"StoneAge":
			rock_reload.play()
		_:
			pass


func play_ShockwaveRoar():
	shockwave_roar.play()

func play_enemyDamage():
	match Globals.era:
		"Modern":
			business_guy_hit.play()
		"Medieval":
			knight_hit.play()
		"StoneAge":
			player_hit_stone_age.play()
		_:
			pass

func play_playerHit():
	match Globals.era:
		"Modern":
			business_guy_hit.play()
		"Medieval":
			pass
		"StoneAge":
			player_hit_stone_age.play()
		_:
			pass

func template():
	match Globals.era:
		"Modern":
			pass
		"Medieval":
			pass
		"StoneAge":
			pass
		_:
			pass
