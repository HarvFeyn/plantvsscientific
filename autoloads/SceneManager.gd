extends Node

signal scene_changed(scene_name: String)

const FADE_DURATION := 0.2

var _transition: CanvasLayer = null
var _color_rect: ColorRect = null
var _is_transitioning := false


func _ready() -> void:
	await get_tree().process_frame  # attend que le viewport soit prêt

	_transition = CanvasLayer.new()
	_transition.layer = 100
	get_tree().root.add_child(_transition)

	_color_rect = ColorRect.new()
	_color_rect.color = Color.BLACK
	_color_rect.size = get_viewport().get_visible_rect().size
	_color_rect.modulate.a = 0.0
	_transition.add_child(_color_rect)


func go_to(path: String) -> void:
	if _is_transitioning:
		return
	
	while _color_rect == null:
		await get_tree().process_frame
	
	_is_transitioning = true
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # ignore les clics pendant la transition
	
	await _fade_in()
	get_tree().change_scene_to_file(path)
	await _fade_out()
	
	_is_transitioning = false
	scene_changed.emit(path)


func _fade_in() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(_color_rect, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished


func _fade_out() -> void:
	await get_tree().create_timer(0.05).timeout
	var tween := get_tree().create_tween()
	tween.tween_property(_color_rect, "modulate:a", 0.0, FADE_DURATION)
	await tween.finished
