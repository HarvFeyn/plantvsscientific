extends Node2D

# ── Configuration ─────────────────────────────────────────────
const TILE_SIZE  := 160
const MAP_WIDTH  := 40
const MAP_HEIGHT := 40

const CAM_SPEED    := 600.0
const CAM_ZOOM_MIN := 0.3
const CAM_ZOOM_MAX := 2.0

# ── Scène de tuile ────────────────────────────────────────────
@export var tile_scene: PackedScene

# ── Grille ────────────────────────────────────────────────────
var grid: Array = []

# ── État ──────────────────────────────────────────────────────
var selected_tile = null
var hovered_tile  = null

# ── Références ────────────────────────────────────────────────
@onready var cam: Camera2D = $Camera2D

# ── Signal ────────────────────────────────────────────────────
signal tile_selected(tile)


func _ready() -> void:
	_generate_grid()
	_setup_camera()


func _process(delta: float) -> void:
	_handle_camera(delta)
	_handle_hover()


# ── Caméra ────────────────────────────────────────────────────

func _setup_camera() -> void:
	cam.limit_left   = 0
	cam.limit_top    = 0
	cam.limit_right  = MAP_WIDTH  * TILE_SIZE
	cam.limit_bottom = MAP_HEIGHT * TILE_SIZE
	# Centre la caméra au milieu de la carte au départ
	cam.position = Vector2(MAP_WIDTH * TILE_SIZE / 2.0, MAP_HEIGHT * TILE_SIZE / 2.0)


func _handle_camera(delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up",   "move_down")
	)
	cam.position += dir * CAM_SPEED / cam.zoom.x * delta

func _input(event: InputEvent) -> void:
	# Zoom molette
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(0.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(-0.1)
		# Clic gauche
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click()


func _zoom(delta: float) -> void:
	var new_zoom: float = clamp(cam.zoom.x + delta, CAM_ZOOM_MIN, CAM_ZOOM_MAX)
	var tween: Tween = create_tween()
	tween.tween_property(cam, "zoom", Vector2(new_zoom, new_zoom), 0.1)

# ── Clic ──────────────────────────────────────────────────────

func _handle_click() -> void:
	var pos := get_global_mouse_position()
	var x := int(pos.x / TILE_SIZE)
	var y := int(pos.y / TILE_SIZE)
	var tile = get_tile(x, y)
	if tile:
		_on_tile_clicked(tile)


func _on_tile_clicked(tile) -> void:
	if selected_tile != null:
		selected_tile.deselect()
	if selected_tile == tile:
		selected_tile = null
		return
	tile.select()
	selected_tile = tile
	tile_selected.emit(tile)


# ── Hover ─────────────────────────────────────────────────────

func _handle_hover() -> void:
	var pos := get_global_mouse_position()
	var x := int(pos.x / TILE_SIZE)
	var y := int(pos.y / TILE_SIZE)
	var tile = get_tile(x, y)

	if tile == hovered_tile:
		return

	if hovered_tile != null and not hovered_tile.is_selected:
		hovered_tile.highlight.hide()

	hovered_tile = tile
	if hovered_tile != null and not hovered_tile.is_selected:
		hovered_tile.highlight.color = Color(1, 1, 1, 0.15)
		hovered_tile.highlight.show()


# ── Génération ────────────────────────────────────────────────

func _generate_grid() -> void:
	grid.resize(MAP_WIDTH)
	for x in MAP_WIDTH:
		grid[x] = []
		grid[x].resize(MAP_HEIGHT)

	for x in MAP_WIDTH:
		for y in MAP_HEIGHT:
			var tile = tile_scene.instantiate()
			tile.grid_x   = x
			tile.grid_y   = y
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			$GridContainer.add_child(tile)
			grid[x][y] = tile
			tile.set_type(_random_type())


func _random_type() -> int:
	var r := randf()
	if   r < 0.50: return 0  # PLAIN
	elif r < 0.70: return 1  # FOREST
	elif r < 0.82: return 2  # MOUNTAIN
	elif r < 0.90: return 3  # WATER
	else:          return 4  # EMPTY


# ── API publique ──────────────────────────────────────────────

func get_tile(x: int, y: int):
	if x < 0 or x >= MAP_WIDTH or y < 0 or y >= MAP_HEIGHT:
		return null
	return grid[x][y]


func get_neighbors(x: int, y: int) -> Array:
	var neighbors := []
	for offset in [Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,0), Vector2i(1,0)]:
		var t = get_tile(x + offset.x, y + offset.y)
		if t: neighbors.append(t)
	return neighbors


func focus_tile(x: int, y: int) -> void:
	var target := Vector2(x * TILE_SIZE + TILE_SIZE / 2.0, y * TILE_SIZE + TILE_SIZE / 2.0)
	var tween := create_tween()
	tween.tween_property(cam, "position", target, 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
