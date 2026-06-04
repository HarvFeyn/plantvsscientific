extends Node

signal scene_changed(scene_name: String)

const FADE_DURATION := 0.4

var _transition: CanvasLayer = null
var _color_rect: ColorRect = null
var _is_transitioning := false
const RIDEAU_HAUT_TEX := preload("uid://crd57adsuxhwv")
const RIDEAU_BAS_TEX  := preload("uid://702f0ev8kmmc")
const rideau_sfx :AudioStream= preload("uid://dmuquyefqvkg7")
var _rideau_haut: Sprite2D = null
var _rideau_bas: Sprite2D = null

func _ready() -> void:
	await get_tree().process_frame

	_transition = CanvasLayer.new()
	_transition.layer = 100
	get_tree().root.add_child(_transition)

	var viewport_size := get_viewport().get_visible_rect().size

	# Rideau haut — part du haut, descend vers le centre
	_rideau_haut = Sprite2D.new()
	_rideau_haut.texture = RIDEAU_HAUT_TEX
	_rideau_haut.centered = false
	_rideau_haut.position = Vector2(0, -viewport_size.y)  # caché au dessus
	_transition.add_child(_rideau_haut)

	# Rideau bas — part du bas, monte vers le centre
	_rideau_bas = Sprite2D.new()
	_rideau_bas.texture = RIDEAU_BAS_TEX
	_rideau_bas.centered = false
	_rideau_bas.position = Vector2(0, viewport_size.y)  # caché en dessous
	_transition.add_child(_rideau_bas)
	_rideau_haut.scale = Vector2(3, 3)
	_rideau_bas.scale = Vector2(3, 3)
	_color_rect = ColorRect.new()
	_color_rect.color = Color.BLACK
	_color_rect.size = get_viewport().get_visible_rect().size
	_color_rect.modulate.a = 0.0
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition.add_child(_color_rect)
	

func go_to(path: String) -> void:
	if _is_transitioning:
		return
	
	while _rideau_haut == null:
		await get_tree().process_frame
	
	_is_transitioning = true
	await _fade_in()
	get_tree().change_scene_to_file(path)
	await _fade_out()
	_is_transitioning = false
	scene_changed.emit(path)


func _fade_in() -> void:
	AudioManager.play_sfx(
		rideau_sfx, -15
	)
	var viewport_size := get_viewport().get_visible_rect().size
	var tween := get_tree().create_tween().set_parallel()
	tween.tween_property(_rideau_haut, "position:y", 0.0, FADE_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_rideau_bas, "position:y", viewport_size.y / 10.0, FADE_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	# Démarre lentement et accélère vers la fin
	tween.tween_property(_color_rect, "modulate:a", 0.7, FADE_DURATION)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished


func _fade_out() -> void:
	await get_tree().create_timer(0.05).timeout
	var viewport_size := get_viewport().get_visible_rect().size
	var tween := get_tree().create_tween().set_parallel()
	tween.tween_property(_rideau_haut, "position:y", -viewport_size.y, FADE_DURATION)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_rideau_bas, "position:y", viewport_size.y, FADE_DURATION)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	# Commence fort et ralentit vers la fin — miroir du fade in
	tween.tween_property(_color_rect, "modulate:a", 0.0, FADE_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished
