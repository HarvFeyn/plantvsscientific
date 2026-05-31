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

const CADRE_SPRITE := preload("res://assets/sprites/cadre_all.png")
const INFESTATION_SPRITE := preload("res://assets/sprites/orobanche.png")
const COUT_BASE    := 20
const COUT_PAR_PAS := 10

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
	infestation.scale = Vector2(2, 2)
	infestation.position = Vector2(-45, -50)
	infestation.hide()

	# Colza — basé sur la variable colzas
	colza_sprite.texture = COLZA_SPRITES[colzas]
	colza_sprite.centered = false
	colza_sprite.scale = Vector2(2, 2)
	
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
	infestation.show()

func disinfest() -> void:
	is_infested = false
	infestation.hide()

func get_cout() -> int:
	if is_infested:
		return 0
	var distance: int = abs(grid_x - 4) + abs(grid_y - 2)
	return COUT_BASE + distance * COUT_PAR_PAS
	
func calculate_rendement() -> void:
	var multi_terre = 1
	match terre:
		TerreType.ARGILE: multi_terre = 1.5
		TerreType.LIMON: multi_terre = 1
		TerreType.TERRE_DE_GROIE: multi_terre = 2
	rendement = ceil((colzas - eau + 2) * 2 * multi_terre)
