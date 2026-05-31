extends Node

const MY_FONT := preload("uid://fi2wiv07digh")

func _ready() -> void:
	var theme := Theme.new()
	theme.set_font("font", "Label", MY_FONT)
	theme.set_font("font", "Button", MY_FONT)
	get_tree().root.theme = theme
