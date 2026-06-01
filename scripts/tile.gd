extends Node2D
 
# ── Signal émis au clic, écouté par le MapManager ────────────
signal tile_clicked(tile)
 
# ── Données de la case (adapte selon ton jeu) ─────────────────
@export var grid_x: int = 0
@export var grid_y: int = 0
 
var building = null
var is_infested: bool = false
var rendement: int = 5

# ── Références ────────────────────────────────────────────────
@onready var sprite: Sprite2D = $Sprite2D
@onready var highlight: ColorRect = $Highlight
@onready var infestation: Sprite2D = $Infestation
@onready var cadre: Sprite2D = $Cadre
var is_blocked: bool = false
@onready var bloqueur: AnimatedSprite2D = $Bloqueur
var is_blocked_temp: bool = false
@onready var bloqueur_temp: AnimatedSprite2D = $BloqueurTemp
var font := load("uid://fi2wiv07digh")

const CADRE_SPRITE := preload("res://assets/sprites/cadre_all.png")
const INFESTATION_SPRITE := preload("res://assets/sprites/orobanche.png")
const COUT_BASE  := 25

const TERRE_SPRITES := [
	preload("res://assets/sprites/limon.png"),
	preload("res://assets/sprites/argile.png"),
	preload("res://assets/sprites/terre.png"),
]

@onready var colza_sprite: Sprite2D = $ColzaSprite

const COLZA_SPRITES := [
	preload("res://assets/sprites/colza0.png"),
	preload("res://assets/sprites/colza1.png"),
	preload("res://assets/sprites/colza2.png")
]

@onready var water_sprite: Sprite2D = $WaterSprite

const WATER_SPRITES := [
	preload("res://assets/sprites/water1.png"),
	preload("res://assets/sprites/water2.png")
]

enum TerreType { LIMON, ARGILE, TERRE_DE_GROIE }

var colzas: int = 1
var eau: int = 1
var terre: TerreType


func _ready() -> void:
	highlight.hide()

	# Terre — basé sur la variable terre
	sprite.texture = TERRE_SPRITES[terre]
	sprite.centered = false
	sprite.scale = Vector2(2, 2)

	# Infestation
	infestation.texture = INFESTATION_SPRITE
	infestation.centered = false
	infestation.scale = Vector2(1.9, 1.9)
	infestation.position = Vector2(-50, -60)
	infestation.hide()

	# Colza — basé sur la variable colzas
	colza_sprite.texture = COLZA_SPRITES[colzas]
	colza_sprite.centered = false
	colza_sprite.scale = Vector2(2, 2)
	
	bloqueur.centered = false
	bloqueur.scale = Vector2(2, 2)
	bloqueur.hide()
	bloqueur_temp.hide()
	
	cadre.texture = CADRE_SPRITE
	cadre.centered = false
	cadre.scale = Vector2(2, 2)
	
	# Eau — 0 = pas d'eau, 1 ou 2 = sprite eau
	if eau > 0:
		water_sprite.texture = WATER_SPRITES[eau - 1]  # eau 1→index 0, eau 2→index 1
		water_sprite.centered = false
		water_sprite.scale = Vector2(2, 2)
	else:
		water_sprite.hide()

# ── Sélection ────────────────────────────────────────────────
 
func select() -> void:
	highlight.show()
 
func deselect() -> void:
	highlight.hide()
 
func infest() -> void:
	is_infested = true
	infestation.modulate.a = 0.0
	infestation.show()
	var tween := create_tween()
	tween.tween_property(infestation, "modulate:a", 1.0, 3.0)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func disinfest() -> void:
	is_infested = false
	infestation.hide()

func get_cout() -> int:
	if is_infested or is_blocked or is_blocked_temp:
		return 0
	var avancement_multi: float = 2.0 + (GameManager.avancement_enemy / 10)
	return int(ceil(COUT_BASE * ModifierManager.cout_multi * avancement_multi))
	
#func get_cout() -> int:
	#if is_infested or is_blocked or is_blocked_temp:
		#return 0
	#var distance: int = abs(grid_x - 4) + abs(grid_y - 2) - 1
	#return COUT_BASE + distance * COUT_PAR_PAS

func calculate_rendement() -> void:
	var multi_terre = 1
	match terre:
		TerreType.ARGILE: multi_terre = 1.3 * ModifierManager.multi_argile
		TerreType.LIMON: multi_terre = 1 * ModifierManager.multi_limon
		TerreType.TERRE_DE_GROIE: multi_terre = 1.6 * ModifierManager.multi_terre_groie
	rendement = ceil((colzas - eau + 3) * 2 * multi_terre)

func block() -> void:
	is_blocked = true
	rendement = 0
	colza_sprite.hide()
	water_sprite.hide()
	bloqueur.show()
	bloqueur.play("appear")
	if is_infested:
		disinfest()

func block_temp() -> void:
	is_blocked_temp = true
	bloqueur_temp.show()
	bloqueur_temp.play("appear")
	if is_infested:
		disinfest()

func unblock_temp() -> void:
	is_blocked_temp = false
	bloqueur_temp.hide()
	infest()

func show_income(amount: int) -> void:
	var font := load("res://assets/fonts/W95F.otf")
	var text := "+" + str(amount)
	
	# Label ombre noire derrière
	var shadow := Label.new()
	shadow.text = text
	shadow.add_theme_font_override("font", font)
	shadow.add_theme_font_size_override("font_size", 24)
	shadow.add_theme_color_override("font_color", Color.BLACK)
	shadow.position = Vector2(64 + 2, 64 + 2)
	add_child(shadow)
	
	# Label vert devant
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color("b3ff61ff"))
	label.position = Vector2(64, 64)
	add_child(label)
	
	# Anime les deux ensemble
	var tween := create_tween().set_parallel()
	tween.tween_property(label,  "position:y", label.position.y  - 80, 1.0)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(shadow, "position:y", shadow.position.y - 80, 1.0)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label,  "modulate:a", 0.0, 1.0)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(shadow, "modulate:a", 0.0, 1.0)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	label.queue_free()
	shadow.queue_free()
