extends Node
 
func _ready() -> void:
	# Dès que la scène principale est chargée, on va au menu
	# On utilise call_deferred pour laisser le temps à tous les autoloads
	# (SceneManager, AudioManager, GameManager) de finir leur _ready()
	SceneManager.go_to.call_deferred(GameManager.SCENE_MENU)
