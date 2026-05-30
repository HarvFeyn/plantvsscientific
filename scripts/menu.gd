extends Control


func _on_play_pressed() -> void:
	GameManager.start_game()


func _on_quit_pressed() -> void:
	GameManager.quit_game()
