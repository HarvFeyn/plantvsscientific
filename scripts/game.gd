extends Node2D

func _ready() -> void:
	# Assure que le jeu n'est pas en pause en arrivant ici
	GameManager.set_pause(false)
 
 
func _unhandled_input(event: InputEvent) -> void:
	# Échap pour retourner au menu (pratique en jam)
	if event.is_action_pressed("ui_cancel"):
		GameManager.go_to_menu()
 
 
# Appelle cette fonction quand le joueur perd
func game_over() -> void:
	# Exemple : attendre 1s puis retourner au menu
	await get_tree().create_timer(1.0).timeout
	GameManager.go_to_menu()
