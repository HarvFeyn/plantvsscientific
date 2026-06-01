extends Node2D

# ── Configuration ─────────────────────────────────────────────
const TILE_SIZE := 128
const MAP_WIDTH  := 30
const MAP_HEIGHT := 20

# ── Scène de tuile ────────────────────────────────────────────
@export var tile_scene: PackedScene

# ── Grille ────────────────────────────────────────────────────
var grid: Array = []

# ── État ──────────────────────────────────────────────────────
var hovered_tile  = null

# ── Nodes créés par code ──────────────────────────────────────
var grid_container: Node2D
var tooltip:        PanelContainer
var tooltip_label:  Label
var tooltip_icon:  TextureRect
var tooltip_icon2: TextureRect
var tooltip_action_label: Label

# ── Signal ────────────────────────────────────────────────────
signal tile_selected(tile)

signal tile_hovered(tile)
const ICON_GRAINE  := preload("res://assets/sprites/graine_cout.png")
const ICON_FLECHE  := preload("res://assets/sprites/fleche_rendement.png")

const START_X := 15
const START_Y := 10
var ui_hovered: bool = false
var enemy_hovered: bool = false
var font := load("res://assets/fonts/W95F.otf")

func _ready() -> void:
	# ── GridContainer ─────────────────────────────────────────
	grid_container = Node2D.new()
	grid_container.name = "GridContainer"
	add_child(grid_container)

	# ── Tooltip ───────────────────────────────────────────────
	var tooltip_layer := CanvasLayer.new()
	tooltip_layer.layer = 5
	add_child(tooltip_layer)

	tooltip = PanelContainer.new()
	tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var stylebox := StyleBoxFlat.new()
	stylebox.set_content_margin_all(5)
	stylebox.bg_color = Color("1a1612")
	stylebox.border_color = Color("4a3f2f")
	stylebox.set_border_width_all(2)
	tooltip.add_theme_stylebox_override("panel", stylebox)
	tooltip_layer.add_child(tooltip)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 5)
	tooltip.add_child(vbox)

	var hbox := HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", -15)
	vbox.add_child(hbox)

	# 1. Label valeur
	tooltip_label = Label.new()
	tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(tooltip_label)

	# 2. Icône graine
	tooltip_icon = TextureRect.new()
	tooltip_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tooltip_icon.custom_minimum_size = Vector2(24, 24)
	tooltip_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(tooltip_icon)

	# 3. Icône flèche
	var icon2 := TextureRect.new()
	icon2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon2.custom_minimum_size = Vector2(24, 24)
	icon2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(icon2)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tooltip_icon2 = icon2

	# Label action en bas
	var action_label := Label.new()
	action_label.text = "Cliquer pour infester"
	action_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_label.add_theme_color_override("font_color", Color("8a7d6a"))
	vbox.add_child(action_label)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tooltip_action_label = action_label
	
	tooltip_label.add_theme_font_override("font", font)
	tooltip_label.add_theme_font_size_override("font_size", 16)
	action_label.add_theme_font_override("font", font)
	action_label.add_theme_font_size_override("font_size", 16)
	tooltip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	tooltip.hide()

	# ── Génération ────────────────────────────────────────────
	_generate_grid()

func _process(_delta: float) -> void:
	_handle_hover()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if ui_hovered:
			# le clic est sur le bouton UI
			tile_selected.emit(null)  # signal vide pour ne rien faire
			return
		_handle_click()

# ── Clic ──────────────────────────────────────────────────────

func _handle_click() -> void:
	print("ui_hovered : ", ui_hovered)
	if ui_hovered:
		return
	var pos := get_global_mouse_position()
	pos.y -= 48
	var x := int(pos.x / TILE_SIZE)
	var y := int(pos.y / TILE_SIZE)
	var tile = get_tile(x, y)
	if tile:
		_on_tile_clicked(tile)

func _on_tile_clicked(tile) -> void:
	tile_selected.emit(tile)


func _handle_hover() -> void:
	if ui_hovered:
		if hovered_tile != null:
			hovered_tile.highlight.hide()
			hovered_tile = null
		tooltip.hide()
		return
	var pos := get_global_mouse_position()
	pos.y -= 48
	var x := int(pos.x / TILE_SIZE)
	var y := int(pos.y / TILE_SIZE)
	var tile = get_tile(x, y)

	if tile == hovered_tile:
		_update_tooltip_position()
		return

	if hovered_tile != null:
		hovered_tile.highlight.hide()

	hovered_tile = tile

	if hovered_tile != null:
		hovered_tile.highlight.show()
		tile_hovered.emit(hovered_tile)
		_show_tooltip(hovered_tile)
	else:
		tooltip.hide()
		tile_hovered.emit(null)
		

func _show_tooltip(tile) -> void:
	if !enemy_hovered:
		if tile.is_infested:
			tooltip_label.text = "Production : Entre " + str(tile.rendement) + " et " + str(tile.rendement+2)
			tooltip_label.add_theme_color_override("font_color", Color("4a8a2a"))
			tooltip_icon.texture = ICON_GRAINE
			tooltip_icon.show()
			tooltip_icon2.texture = ICON_FLECHE
			tooltip_icon2.show()
			tooltip_action_label.hide()
		else:
			tooltip_label.text = "Coût pour acheter la case : -" + str(tile.get_cout())
			tooltip_label.add_theme_color_override("font_color", Color("c44040"))
			tooltip_icon.texture = ICON_GRAINE
			tooltip_icon2.hide()
			if tile.is_blocked or tile.is_blocked_temp:
				tooltip_action_label.text = "Cette case est bloquée"
				tooltip_action_label.add_theme_color_override("font_color", Color("c44040"))
				tooltip_action_label.show()
			else:
				var has_infested_neighbor := false
				for neighbor in get_neighbors(tile.grid_x, tile.grid_y):
					if neighbor.is_infested:
						has_infested_neighbor = true
						break
				if not has_infested_neighbor:
					tooltip_action_label.text = "Il faut déjà posséder une case adjacente"
					tooltip_action_label.add_theme_color_override("font_color", Color("c44040"))
					tooltip_action_label.show()
				elif GameManager.graines < tile.get_cout():
					tooltip_action_label.text = "Il vous faut plus de graines pour payer cette case"
					tooltip_action_label.add_theme_color_override("font_color", Color("c44040"))
					tooltip_action_label.show()
				else:
					tooltip_action_label.text = "Cliquer pour vous développer"
					tooltip_action_label.add_theme_color_override("font_color", Color("8a7d6a"))
					tooltip_action_label.show()
		_update_tooltip_position()
		tooltip.show()
		tooltip.reset_size()

func _update_tooltip_position() -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var viewport_size := get_viewport().get_visible_rect().size
	var pos := mouse_pos + Vector2(16, 16)
	pos.x = clamp(pos.x, 0, viewport_size.x - tooltip.size.x)
	pos.y = clamp(pos.y, 0, viewport_size.y - tooltip.size.y)
	tooltip.position = pos


# ── Génération ────────────────────────────────────────────────

func _generate_grid() -> void:
	grid.resize(MAP_WIDTH)
	for x in MAP_WIDTH:
		grid[x] = []
		grid[x].resize(MAP_HEIGHT)

	for x in MAP_WIDTH:
		for y in MAP_HEIGHT:
			var tile = tile_scene.instantiate()
			if(x==START_X and y==START_Y):
				tile.colzas = 2
			else:
				tile.colzas = randi() % 3
			tile.eau    = randi() % 3
			tile.terre  = randi() % 3
			tile.grid_x   = x
			tile.grid_y   = y
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			grid_container.add_child(tile)
			grid[x][y] = tile
			tile.calculate_rendement()
	_place_blockers()
	var start_tile = get_tile(START_X, START_Y)
	start_tile.calculate_rendement()
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
	
func regenerate() -> void:
	# Supprime toutes les tuiles existantes
	for child in grid_container.get_children():
		child.queue_free()
	
	# Réinitialise la grille
	grid.clear()
	
	# Regénère
	_generate_grid()

func _place_blockers() -> void:
	# Cases protégées : tuile de départ + ses 4 voisins
	var protected := []
	protected.append(Vector2i(START_X, START_Y))
	for offset in [Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,0), Vector2i(1,0)]:
		protected.append(Vector2i(START_X + offset.x, START_Y + offset.y))

	for x in MAP_WIDTH:
		for y in MAP_HEIGHT:
			# Vérifie si protégée
			if Vector2i(x, y) in protected:
				continue

			# 20% de chance
			if randf() > 0.30:
				continue

			# Vérifie qu'aucun voisin n'est déjà bloqué
			var has_blocked_neighbor := false
			for offset in [Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,0), Vector2i(1,0)]:
				var neighbor = get_tile(x + offset.x, y + offset.y)
				if neighbor != null and neighbor.is_blocked:
					has_blocked_neighbor = true
					break

			if not has_blocked_neighbor:
				grid[x][y].block()

func show_custom_tooltip(text: String) -> void:
	tooltip_label.text = text
	tooltip_action_label.hide()
	tooltip_icon.hide()
	tooltip_icon2.hide()
	_update_tooltip_position()
	tooltip.show()
	tooltip.reset_size()
	
func hide_tooltip() -> void:
	tooltip.hide()
