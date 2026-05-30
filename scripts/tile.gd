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
 
# ── Références ────────────────────────────────────────────────
@onready var sprite: ColorRect = $Sprite2D
@onready var highlight: ColorRect = $Highlight
 
 
func _ready() -> void:
	highlight.hide()
 
# ── Sélection ────────────────────────────────────────────────
 
func select() -> void:
	is_selected = true
	highlight.color = Color("3a3a3a")
	highlight.show()
 
func deselect() -> void:
	is_selected = false
	highlight.hide()
 
 
# ── Visuel selon le type ──────────────────────────────────────
 
func set_type(new_type: TileType) -> void:
	type = new_type
	# Adapte les couleurs à tes sprites — ici placeholder coloré
	match type:
		TileType.PLAIN:    sprite.color = Color("5a8a3a")
		TileType.FOREST:   sprite.color = Color("2a5a2a")
		TileType.MOUNTAIN: sprite.color = Color("7a6a5a")
		TileType.WATER:    sprite.color = Color("2a5a8a")
		TileType.EMPTY:    sprite.color = Color("3a3a3a")
