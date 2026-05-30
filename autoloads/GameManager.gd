extends Node

# Signals utiles pour l'UI et les autres systèmes
signal score_changed(new_score: int)
signal game_paused(is_paused: bool)

# Chemins des scènes — modifie-les selon ton projet
const SCENE_MENU := "res://scenes/menu.tscn"
const SCENE_GAME := "res://scenes/game.tscn"

var is_paused: bool = false
var high_score: int = 0


# --- Navigation rapide ---

func start_game() -> void:
	SceneManager.go_to(SCENE_GAME)


func go_to_menu() -> void:
	SceneManager.go_to(SCENE_MENU)


# --- Pause ---

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	game_paused.emit(is_paused)


func set_pause(value: bool) -> void:
	is_paused = value
	get_tree().paused = is_paused
	game_paused.emit(is_paused)


# --- Quitter ---

func quit_game() -> void:
	get_tree().quit()
