extends Control

# Durée d'affichage avant de passer automatiquement au jeu
const DISPLAY_TIME := 3.0

func _ready() -> void:
	pass
	# Passe au jeu automatiquement après DISPLAY_TIME secondes
	#await get_tree().create_timer(DISPLAY_TIME).timeout
	#GameManager.start_game()

func _input(event: InputEvent) -> void:
	# Ou au clic / touche pour passer plus vite
	if event is InputEventMouseButton and event.pressed:
		GameManager.start_game()
	if event is InputEventKey and event.pressed:
		GameManager.start_game()


func _on_button_pressed() -> void:
	GameManager.start_game()
