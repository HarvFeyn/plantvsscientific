extends Node

# Noms des bus audio à créer dans Project > Audio (onglet bas de Godot)
# Bus "Music" et bus "SFX" branchés sur Master
const BUS_MUSIC := "Music"
const BUS_SFX   := "SFX"

var _music_player: AudioStreamPlayer


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)
	AudioManager.play_music(preload("uid://crkmrcvp3wnj8"),-6.0)
	
# --- Musique ---

func play_music(stream: AudioStream, volume_db := 0.0) -> void:
	if _music_player.stream == stream and _music_player.playing:
		return  # Déjà en train de jouer ce morceau
	_music_player.stream = stream
	_music_player.volume_db = volume_db
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


# Transition douce entre deux musiques
func crossfade_music(stream: AudioStream, duration := 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", -60.0, duration)
	await tween.finished
	play_music(stream)
	_music_player.volume_db = -60.0
	var tween2 := create_tween()
	tween2.tween_property(_music_player, "volume_db", 0.0, duration)


# --- SFX ---

# Joue un son à la position du node appelant (ou en 2D avec AudioStreamPlayer2D)
func play_sfx(stream: AudioStream, volume_db := 0.0) -> void:
	var player := AudioStreamPlayer.new()
	player.bus = BUS_SFX
	player.stream = stream
	player.volume_db = volume_db
	player.autoplay = true
	add_child(player)
	# Se supprime automatiquement quand le son est fini
	player.finished.connect(player.queue_free)


# --- Volume global ---

func set_music_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MUSIC), linear_to_db(linear))


func set_sfx_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_SFX), linear_to_db(linear))
