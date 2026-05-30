extends Node2D

# ── Configuration ─────────────────────────────────────────────
const TILE_SIZE  := 192
const MAP_WIDTH  := 40
const MAP_HEIGHT := 40

# ── Scène de tuile ────────────────────────────────────────────
@export var tile_scene: PackedScene

# ── Grille ────────────────────────────────────────────────────
var grid: Array = []

# ── État ──────────────────────────────────────────────────────
var selected_tile = null
var hovered_tile  = null

# ── Nodes créés par code ──────────────────────────────────────
var grid_container: Node2D
var tooltip:        PanelContainer
var tooltip_label:  Label
var tooltip_icon:  TextureRect
var tooltip_action_label: Label

# ── Signal ────────────────────────────────────────────────────
signal tile_selected(tile)

const ICON_GRAINE  := preload("res://assets/sprites/graine_cout.png")
const ICON_FLECHE  := preload("res://assets/sprites/fleche_rendement.png")

func _ready() -> void:
	# GridContainer
	grid_container = Node2D.new()
	grid_container.name = "GridContainer"
	add_child(grid_container)

	# Tooltip
	var tooltip_layer := CanvasLayer.new()
	tooltip_layer.layer = 5
	add_child(tooltip_layer)

	tooltip = PanelContainer.new()
	tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_layer.add_child(tooltip)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip.add_child(vbox)

	var hbox := HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(hbox)

	tooltip_icon = TextureRect.new()
	tooltip_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tooltip_icon.custom_minimum_size = Vector2(24, 24)
	tooltip_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE


	tooltip_label = Label.new()
	tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(tooltip_label)
	hbox.add_child(tooltip_icon)
	
	var action_label := Label.new()
	action_label.text = "Cliquer pour infester"
	action_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(action_label)
	tooltip_action_label = action_label

	tooltip.hide()
	tooltip.hide()
	_generate_grid()
	

func _process(_delta: float) -> void:
	_handle_hover()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("clic reçu dans map.gd")
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click()


# ── Clic ──────────────────────────────────────────────────────

func _handle_click() -> void:
	print("handle click")
	var pos := get_global_mouse_position()
	var x := int(pos.x / TILE_SIZE)
	var y := int(pos.y / TILE_SIZE)
	var tile = get_tile(x, y)
	if tile:
		_on_tile_clicked(tile)

func _on_tile_clicked(tile) -> void:
	print("tile clicked dans map")
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
		_update_tooltip_position()
		return

	if hovered_tile != null and not hovered_tile.is_selected:
		hovered_tile.highlight.hide()

	hovered_tile = tile

	if hovered_tile != null and not hovered_tile.is_selected:
		hovered_tile.highlight.color = Color(1, 1, 1, 0.15)
		hovered_tile.highlight.show()
		_show_tooltip(hovered_tile)
	else:
		tooltip.hide()

func _show_tooltip(tile) -> void:
	if tile.is_infested:
		tooltip_icon.texture = ICON_FLECHE
		tooltip_label.text = str(tile.rendement)
		tooltip_action_label.hide()
	else:
		tooltip_icon.texture = ICON_GRAINE
		tooltip_label.text = str(tile.get_cout())
		tooltip_action_label.show()
	_update_tooltip_position()
	tooltip.show()

func _update_tooltip_position() -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	tooltip.position = mouse_pos + Vector2(16, 16)


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
			grid_container.add_child(tile)
			grid[x][y] = tile
	var start_tile = get_tile(0, 0)
	start_tile.infest()

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


func get_map_size() -> Vector2:
	return Vector2(MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * TILE_SIZE)
