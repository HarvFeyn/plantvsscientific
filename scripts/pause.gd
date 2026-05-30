extends CanvasLayer
 
# Ce node doit avoir process_mode = WHEN_PAUSED
# pour continuer à fonctionner quand le jeu est en pause
 
@onready var volume_slider: HSlider = $Panel/VBoxContainer/HBoxVolume/HSlider
 
 
func _ready() -> void:
	# Cache le menu au départ
	hide()
	# Écoute le signal de pause du GameManager
	GameManager.game_paused.connect(_on_game_paused)
	# Init le slider sur le volume actuel du bus Master
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
 
 
func _on_game_paused(is_paused: bool) -> void:
	if is_paused:
		show()
	else:
		hide()
 
 
func _on_resume_button_pressed() -> void:
	GameManager.set_pause(false)
 
 
func _on_menu_button_pressed() -> void:
	GameManager.set_pause(false)  # dépause avant de changer de scène
	GameManager.go_to_menu()
 
 
func _on_volume_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value)
	AudioManager.set_sfx_volume(value)
 
