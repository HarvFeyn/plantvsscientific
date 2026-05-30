extends Node2D

# ── Configuration caméra ──────────────────────────────────────
const CAM_SPEED    := 600.0

# ── Références ────────────────────────────────────────────────
@onready var cam: Camera2D = $Camera2D
@onready var map: Node2D   = $Map
const COUT_INFESTION: int = 10
@onready var graines_label: Label = $HUD/GrainesDisplay/Label
@onready var terre_type_label: Label = $HUD/DisplayInfoTuile/TerreType
@onready var circle_water_2: TextureRect = $HUD/DisplayInfoTuile/CircleWater2
@onready var circle_water_3: TextureRect = $HUD/DisplayInfoTuile/CircleWater3
@onready var circle_colza_2: TextureRect = $HUD/DisplayInfoTuile/CircleColza2
@onready var circle_colza_3: TextureRect = $HUD/DisplayInfoTuile/CircleColza3

const TURN_BTN_NORMAL := preload("uid://xldyiccvygfc")
const TURN_BTN_HOVER  := preload("uid://nq6syptfxea3")

func _ready() -> void:
	GameManager.set_pause(false)
	cam.make_current()
	_setup_camera()
	map.connect("tile_selected", _on_tile_selected)
	map.connect("tile_hovered", _on_tile_hovered)
	
	GameManager.turn_changed.connect(_on_turn_changed)
	GameManager.graines_changed.connect(_on_graines_changed)
	GameManager.avancement_changed.connect(_on_avancement_changed)
	#turn_button.mouse_entered.connect(_on_turn_button_entered)
	#turn_button.mouse_exited.connect(_on_turn_button_exited)
	
func _process(delta: float) -> void:
	_handle_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos := get_viewport().get_mouse_position()
		#var btn_rect := turn_button.get_global_rect()
		#if btn_rect.has_point(mouse_pos):
			#GameManager.next_turn()
			#get_viewport().set_input_as_handled()
	if event.is_action_pressed("ui_cancel"):
		GameManager.go_to_menu()

# ── Caméra ────────────────────────────────────────────────────

func _setup_camera() -> void:
	var map_size: Vector2 = map.get_map_size()
	cam.limit_left   = 0
	cam.limit_top    = 0
	cam.limit_right  = int(map_size.x)
	cam.limit_bottom = int(map_size.y)
	cam.position     = Vector2(0, 0)
	cam.offset       = Vector2.ZERO

func _handle_camera(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"):  dir.x -= 1
	if Input.is_action_pressed("move_right"): dir.x += 1
	if Input.is_action_pressed("move_up"):    dir.y -= 1
	if Input.is_action_pressed("move_down"):  dir.y += 1


# ── Tuile sélectionnée ────────────────────────────────────────

func _on_tile_selected(tile) -> void:
	if tile.is_infested:
		return
	
	# Vérifie qu'au moins un voisin est infesté
	var neighbors: Array = map.get_neighbors(tile.grid_x, tile.grid_y)
	var has_infested_neighbor := false
	for neighbor in neighbors:
		if neighbor.is_infested:
			has_infested_neighbor = true
			break
	
	if not has_infested_neighbor:
		print("pas de voisin infesté")
		return
	
	var cout: int = tile.get_cout()
	if GameManager.graines < cout:
		print("pas assez de graines, cout : ", cout)
		return
	
	GameManager.graines -= cout
	tile.infest()

# ── Game over ─────────────────────────────────────────────────

func game_over() -> void:
	await get_tree().create_timer(1.0).timeout
	GameManager.go_to_menu()
	

func _on_turn_changed(_turn: int) -> void:
	_process_turn()
	GameManager.avancement_enemy += 2.0
	
func _process_turn() -> void:
	for x in map.MAP_WIDTH:
		for y in map.MAP_HEIGHT:
			var tile = map.get_tile(x, y)
			if tile.is_infested:
				GameManager.graines += tile.rendement + randi() % 3
	_process_enemy_attack()
	
func _on_graines_changed(value: int) -> void:
	graines_label.text = str(value)

func _on_avancement_changed(value: float) -> void:
	$HUD/TopBar/HBoxContainer/HBoxContainer2/Label.text = "Ennemi : %.0f%%" % value

func _reset_game() -> void:
	# Calcule le bonus de graines
	var bonus: int = int(floor(GameManager.graines / 3))
	
	# Remet toutes les tuiles à leur état de base
	for x in map.MAP_WIDTH:
		for y in map.MAP_HEIGHT:
			var tile = map.get_tile(x, y)
			if tile.is_infested:
				tile.is_infested = false
				tile.disinfest()
	# Remet la case (0,0) infestée
	var start_tile = map.get_tile(map.START_X, map.START_Y)
	start_tile.infest()
	
	# Réinitialise les variables globales
	GameManager.avancement_enemy = 0.0
	GameManager.graines = bonus
	GameManager.current_turn = 1
	GameManager.turn_changed.emit(1)


func _on_btn_resets_pressed() -> void:
	_reset_game()

func _process_enemy_attack() -> void:
	var avancement: float = GameManager.avancement_enemy
	
	# Rien en dessous de 20%
	if avancement <= 20.0:
		return
	
	# Calcule le % de chance : chaque tranche de 10% au dessus de 20% = 10% de chance
	# 20-30% → 10%, 30-40% → 20%, 40-50% → 30%...
	var tranches: int = int((avancement - 20.0) / 10.0)
	var chance: float = tranches * 10.0
	
	# Lance le dé
	if randf() * 100.0 > chance:
		return
	
	# Trouve toutes les tuiles infestées
	var infested_tiles := []
	for x in map.MAP_WIDTH:
		for y in map.MAP_HEIGHT:
			var tile = map.get_tile(x, y)
			if tile.is_infested:
				infested_tiles.append(tile)
	
	if infested_tiles.is_empty():
		return
	
	# Choisit une tuile aléatoire et la désinfeste
	var target = infested_tiles[randi() % infested_tiles.size()]
	target.disinfest()

func _on_tile_hovered(tile) -> void:
	if tile == null:
		terre_type_label.text = ""
		return
	match tile.terre:
		0: terre_type_label.text = "Limon"
		1: terre_type_label.text = "Argile"
		2: terre_type_label.text = "Terre de Groie"
	match tile.eau:
		0: 
			circle_water_2.texture = preload("uid://cr18115lapy3f")
			circle_water_3.texture = preload("uid://cr18115lapy3f")
		1:
			circle_water_2.texture = preload("uid://cfo8fr7i7p76t")
			circle_water_3.texture = preload("uid://cr18115lapy3f")
		2: 
			circle_water_2.texture = preload("uid://cfo8fr7i7p76t")
			circle_water_3.texture = preload("uid://cfo8fr7i7p76t")
	match tile.colzas:
		0: 
			circle_colza_2.texture = preload("uid://cr18115lapy3f")
			circle_colza_3.texture = preload("uid://cr18115lapy3f")
		1: 
			circle_colza_2.texture = preload("uid://cen4ss4gsehbq")
			circle_colza_3.texture = preload("uid://cr18115lapy3f")
		2: 
			circle_colza_2.texture = preload("uid://cen4ss4gsehbq")
			circle_colza_3.texture = preload("uid://cen4ss4gsehbq")
			
			
#func _on_turn_button_entered() -> void:
	#turn_button.texture = TURN_BTN_HOVER
	#map.ui_hovered = true

#func _on_turn_button_exited() -> void:
	#turn_button.texture = TURN_BTN_NORMAL
	#map.ui_hovered = false
	#print("ui_hovered : ", map.ui_hovered)
	
#func _on_turn_button_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#GameManager.next_turn()
