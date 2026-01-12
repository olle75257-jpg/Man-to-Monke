extends Node

@onready var gun_shot: AudioStreamPlayer = $Game/Gun/GunShot
@onready var reload: AudioStreamPlayer = $Game/Gun/Reload
@onready var shockwave_roar: AudioStreamPlayer = $Game/Shockwave/ShockwaveRoar
@onready var knight_hit: AudioStreamPlayer = $Game/Era/Medieval/KnightHit
@onready var player_hit_stone_age: AudioStreamPlayer = $Game/PlayerSfx/PlayerHitStoneAge
@onready var rock_reload: AudioStreamPlayer = $Game/Era/StoneAge/RockReload
@onready var business_guy_hit: AudioStreamPlayer = $Game/Era/Modern/BusinessGuyHit
@onready var grenade_explode: AudioStreamPlayer = $Game/Era/Modern/GrenadeExplode
@onready var grenade_fire: AudioStreamPlayer = $Game/Era/Modern/GrenadeFire
@onready var arrow_shoot: AudioStreamPlayer = $Game/Era/Medieval/ArrowShoot
@onready var bow_reload: AudioStreamPlayer = $Game/Era/Medieval/BowReload
@onready var player_hit_modern: AudioStreamPlayer = $Game/PlayerSfx/PlayerHitModern
@onready var player_hit_medieval: AudioStreamPlayer = $Game/PlayerSfx/PlayerHitMedieval
@onready var modern_music: AudioStreamPlayer = $Game/Music/ModernMusic
@onready var medieval_music: AudioStreamPlayer = $Game/Music/MedievalMusic
@onready var stone_age_music: AudioStreamPlayer = $Game/Music/StoneAgeMusic
@onready var story_music: AudioStreamPlayer = $Game/Music/StoryMusic


var current_bgm: AudioStreamPlayer = modern_music 
var fade_duration: float = 1.0

func play_BGM():
	var target_music: AudioStreamPlayer = null
	
	match Globals.era:
		"Intro":
			target_music = story_music
		"Modern":
			target_music = modern_music
		"Medieval":
			target_music = medieval_music
		"StoneAge":
			target_music = stone_age_music
			
	if target_music != current_bgm:
		fade_to_music(target_music)

func fade_to_music(new_bgm: AudioStreamPlayer):
	var tween = create_tween().set_parallel(true)
	
	if current_bgm and current_bgm.playing:
		tween.tween_property(current_bgm, "volume_db", -80.0, fade_duration)
		tween.chain().tween_callback(current_bgm.stop)
	
	if new_bgm:
		new_bgm.volume_db = -80.0 
		new_bgm.play()
		tween.tween_property(new_bgm, "volume_db", 0.0, fade_duration)
	
	current_bgm = new_bgm

func play_shootProjectile():
	match Globals.era:
		"Modern":
			gun_shot.play()
		"Medieval":
			arrow_shoot.play()
		"StoneAge":
			pass
		_:
			pass

func play_reload():
	match Globals.era:
		"Modern":
			reload.play()
		"Medieval":
			bow_reload.play()
		"StoneAge":
			rock_reload.play()
		_:
			pass


func play_ShockwaveRoar():
	shockwave_roar.play()

func play_fireGrenade():
	grenade_fire.play()

func play_grenadeExplode():
	grenade_explode.play()

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
			player_hit_modern.play()
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
