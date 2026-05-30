extends Node2D
 
# ── Signal émis au clic, écouté par le MapManager ────────────
signal tile_clicked(tile)
 
# ── Données de la case (adapte selon ton jeu) ─────────────────
@export var grid_x: int = 0
@export var grid_y: int = 0
 
var is_selected: bool = false
var building = null
var is_infested: bool = false
var rendement: int = 1

# ── Références ────────────────────────────────────────────────
@onready var sprite: Sprite2D = $Sprite2D
@onready var highlight: ColorRect = $Highlight
@onready var infestation: Sprite2D = $Infestation

const INFESTATION_SPRITE := preload("res://assets/sprites/orobanche.png")
const COUT_BASE    := 5
const COUT_PAR_PAS := 2

const TERRE_SPRITES := [
	preload("res://assets/sprites/argile.png"),
	preload("res://assets/sprites/limon.png"),
	preload("res://assets/sprites/terre.png")
]

@onready var colza_sprite: Sprite2D = $ColzaSprite

const COLZA_SPRITES := [
	preload("res://assets/sprites/colza0.png"),
	preload("res://assets/sprites/colza1.png"),
	preload("res://assets/sprites/colza2.png")
]

@onready var water_sprite: Sprite2D = $WaterSprite

const WATER_SPRITES := [
	preload("res://assets/sprites/colza0.png"),
	preload("res://assets/sprites/water1.png"),
	preload("res://assets/sprites/colza2.png")
]

enum TerreType { LIMON, ARGILE, TERRE_DE_GROIE }

var colzas: int = 1
var eau: int = 1
var terre: TerreType = TerreType.ARGILE


func _ready() -> void:
	highlight.hide()
	sprite.texture = TERRE_SPRITES[randi() % TERRE_SPRITES.size()]
	sprite.centered = false
	sprite.scale = Vector2(3, 3)
	
	infestation.texture = INFESTATION_SPRITE
	infestation.centered = false
	infestation.scale = Vector2(3, 3)
	infestation.position = Vector2(-70, -80)
	infestation.hide()
	colza_sprite.texture = COLZA_SPRITES[randi() % COLZA_SPRITES.size()]
	colza_sprite.centered = false
	colza_sprite.scale = Vector2(3, 3)
	water_sprite.texture = WATER_SPRITES[randi() % WATER_SPRITES.size()]
	water_sprite.centered = false
	water_sprite.position = Vector2(-0, 0)
	water_sprite.scale = Vector2(3, 3)
	
# ── Sélection ────────────────────────────────────────────────
 
func select() -> void:
	is_selected = true
	highlight.show()
 
func deselect() -> void:
	is_selected = false
	highlight.hide()
 
func infest() -> void:
	is_infested = true
	infestation.show()

func disinfest() -> void:
	is_infested = false
	infestation.hide()

func _get_cout_infestion(tile) -> int:
	var distance: int = abs(tile.grid_x) + abs(tile.grid_y)
	return 5 + distance * 2

func get_cout() -> int:
	if is_infested:
		return 0
	var distance: int = abs(grid_x) + abs(grid_y)
	return COUT_BASE + distance * COUT_PAR_PAS
