extends Control

const VIDEOS := [
	preload("uid://bwf4xyvwur0nd"),
	preload("uid://cs3ewd1v75duu"),
	preload("uid://b02nvvm5g1d6i"),
	preload("uid://c6vmeqfrcjj3n"),
	preload("uid://cfxlwiwummdvt"),
]

var current_index: int = 0

@onready var video_player: VideoStreamPlayer = $VideoPlayer

func _ready() -> void:
	_play_video(0)

func _play_video(index: int) -> void:
	video_player.stream = VIDEOS[index]
	video_player.play()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		current_index += 1
		if current_index >= VIDEOS.size():
			GameManager.start_game()
		else:
			_play_video(current_index)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameManager.go_to_menu()
