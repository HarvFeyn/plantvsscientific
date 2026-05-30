extends Node2D
 
# ── Signal émis au clic, écouté par le MapManager ────────────
signal tile_clicked(tile)
 
# ── Données de la case (adapte selon ton jeu) ─────────────────
@export var grid_x: int = 0
@export var grid_y: int = 0
 
enum TileType { EMPTY, FOREST, MOUNTAIN, WATER, PLAIN }
var type: TileType = TileType.PLAIN
var is_selected: bool = false
var building = null
var is_infested: bool = false
var rendement: int = 1

# ── Références ────────────────────────────────────────────────
@onready var sprite: ColorRect = $Sprite2D
@onready var highlight: ColorRect = $Highlight
 
const COUT_BASE    := 5
const COUT_PAR_PAS := 2

func _ready() -> void:
	highlight.hide()
 
# ── Sélection ────────────────────────────────────────────────
 
func select() -> void:
	is_selected = true
	highlight.show()
 
func deselect() -> void:
	is_selected = false
	highlight.hide()
 
 
# ── Visuel selon le type ──────────────────────────────────────
 
func set_type(new_type: TileType) -> void:
	if new_type == TileType.WATER: is_infested = true
	type = new_type
	# Adapte les couleurs à tes sprites — ici placeholder coloré
	match type:
		TileType.PLAIN:    sprite.color = Color("5a8a3a")
		TileType.FOREST:   sprite.color = Color("2a5a2a")
		TileType.MOUNTAIN: sprite.color = Color("7a6a5a")
		TileType.WATER:    sprite.color = Color("2a5a8a")
		TileType.EMPTY:    sprite.color = Color("3a3a3a")

func _get_cout_infestion(tile) -> int:
	var distance: int = abs(tile.grid_x) + abs(tile.grid_y)
	return 5 + distance * 2

func get_cout() -> int:
	if is_infested:
		return 0
	var distance: int = abs(grid_x) + abs(grid_y)
	return COUT_BASE + distance * COUT_PAR_PAS
