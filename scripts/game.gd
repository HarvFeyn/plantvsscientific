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
@onready var turn_button: TextureRect = $HUD/TurnControl/TurnButton
@onready var turn_income: Label = $HUD/TurnControl/TurnIcome
@onready var reset_button_area: Control = $HUD/ResetButtonArea
@onready var reset_button: AnimatedSprite2D = $HUD/ResetButtonArea/ResetButton
@onready var percent_enemy: Label = $HUD/EnemyControl/PercentEnemy
@onready var enemy_marker: TextureRect = $HUD/EnemyControl/ProgressTrack/EnemyMarker
@onready var progress_track: Control = $HUD/EnemyControl/ProgressTrack
@onready var popup_reset: Control = $HUD/PopupReset
@onready var btn_confirm: Control = $HUD/PopupReset/BtnConfirm
@onready var btn_cancel:  Control = $HUD/PopupReset/BtnCancel
@onready var popup_reset_control: Control = $HUD/PopupReset
@onready var btn_confirm_reset: Button = $HUD/PopupReset/BtnConfirm
@onready var btn_cancel_reset:  Button = $HUD/PopupReset/BtnCancel
@onready var overlay: ColorRect = $HUD/PopupReset/Overlay

@onready var shop_popup: Control   = $HUD/ShopPopup
@onready var shop_overlay: ColorRect = $HUD/ShopPopup/ShopOverlay
@onready var card_names:  Array    = [
	$HUD/ShopPopup/ShopContent/Cards/PanelCard1/MarginCard1/Card1/InfosCard1/CardName1,
	$HUD/ShopPopup/ShopContent/Cards/PanelCard2/MarginCard2/Card2/InfosCard2/CardName2,
	$HUD/ShopPopup/ShopContent/Cards/PanelCard3/MarginCard3/Card3/InfosCard3/CardName3,
]
@onready var card_descs:  Array    = [
	$HUD/ShopPopup/ShopContent/Cards/PanelCard1/MarginCard1/Card1/InfosCard1/CardDesc1,
	$HUD/ShopPopup/ShopContent/Cards/PanelCard2/MarginCard2/Card2/InfosCard2/CardDesc2,
	$HUD/ShopPopup/ShopContent/Cards/PanelCard3/MarginCard3/Card3/InfosCard3/CardDesc3,
]
@onready var card_costs:  Array    = [
	$HUD/ShopPopup/ShopContent/Cards/PanelCard1/MarginCard1/Card1/InfosCard1/HBoxContainer/CardCost1,
	$HUD/ShopPopup/ShopContent/Cards/PanelCard2/MarginCard2/Card2/InfosCard2/HBoxContainer/CardCost2,
	$HUD/ShopPopup/ShopContent/Cards/PanelCard3/MarginCard3/Card3/InfosCard3/HBoxContainer/CardCost3,
]
@onready var buy_buttons: Array    = [
	$HUD/ShopPopup/ShopContent/Cards/PanelCard1/MarginCard1/Card1/BuyBtn1,
	$HUD/ShopPopup/ShopContent/Cards/PanelCard2/MarginCard2/Card2/BuyBtn2,
	$HUD/ShopPopup/ShopContent/Cards/PanelCard3/MarginCard3/Card3/BuyBtn3,
]
@onready var close_shop_btn: Button = $HUD/ShopPopup/ShopContent/CloseShop

@onready var improvements_panel: Control = $HUD/ImprovementsPanel
@onready var improvements_list: PanelContainer = $HUD/ImprovementsPanel/ImprovementsList
@onready var improvements_content: VBoxContainer = $HUD/ImprovementsPanel/ImprovementsList/ImprovementsContent
@onready var improvements_header: Panel = $HUD/ImprovementsPanel/ImprovementsHeader
@onready var enemy_control: Control = $HUD/EnemyControl

const MUSIC_NORMAL := preload("uid://crkmrcvp3wnj8")
const MUSIC_INTENSE := preload("uid://d1d6gtcxttnrg")

var _music_intense_playing := false

var hovered_button: String = ""

const TURN_BTN_NORMAL := preload("uid://xldyiccvygfc")
const TURN_BTN_HOVER  := preload("uid://nq6syptfxea3")
const TURN_BTN_CLICK  := preload("uid://cdx0lfhgvh5h2")

var turn_income_value: int = 0

var _dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO
var _cam_start: Vector2 = Vector2.ZERO
var _displayed_graines: int = 0

const CAM_ZOOM_MIN := 0.5
const CAM_ZOOM_MAX := 1

func _ready() -> void:
	GameManager.set_pause(false)
	cam.make_current()
	_setup_camera()
	map.connect("tile_selected", _on_tile_selected)
	map.connect("tile_hovered", _on_tile_hovered)
	
	GameManager.turn_changed.connect(_on_turn_changed)
	GameManager.graines_changed.connect(_on_graines_changed)
	GameManager.avancement_changed.connect(_on_avancement_changed)
	turn_button.mouse_entered.connect(_on_turn_button_entered)
	turn_button.mouse_exited.connect(_on_turn_button_exited)
	reset_button_area.mouse_entered.connect(_on_reset_button_entered)
	reset_button_area.mouse_exited.connect(_on_reset_button_exited)
	var frame_size := reset_button.sprite_frames.get_frame_texture("hover", 0).get_size()
	reset_button_area.custom_minimum_size = Vector2(frame_size.x * 3, frame_size.y * 1.2)
	reset_button_area.size = Vector2(frame_size.x * 3, frame_size.y * 1.2)
	turn_button.mouse_entered.connect(_on_turn_button_entered)
	turn_button.mouse_exited.connect(_on_turn_button_exited)
	popup_reset.hide()
	btn_confirm.mouse_entered.connect(func(): hovered_button = "confirm")
	btn_confirm.mouse_exited.connect(func():  hovered_button = "")
	btn_cancel.mouse_entered.connect(func():  hovered_button = "cancel")
	btn_cancel.mouse_exited.connect(func():   hovered_button = "")
	popup_reset_control.hide()
	btn_confirm_reset.pressed.connect(_confirm_reset)
	btn_cancel_reset.pressed.connect(_cancel_reset)
	overlay.mouse_entered.connect(func(): map.ui_hovered = true)
	overlay.mouse_exited.connect(func():  map.ui_hovered = false)
	enemy_control.mouse_entered.connect(func(): map.enemy_hovered = true)
	enemy_control.mouse_exited.connect(func():  map.enemy_hovered = false)
	overlay.mouse_entered.connect(func(): map.ui_hovered = true)
	btn_confirm.mouse_entered.connect(func(): 
		map.ui_hovered = true
		hovered_button = "confirm"
	)
	btn_cancel.mouse_entered.connect(func(): 
		map.ui_hovered = true
		hovered_button = "cancel"
	)
	btn_confirm.mouse_exited.connect(func(): hovered_button = "")
	btn_cancel.mouse_exited.connect(func(): hovered_button = "")
	_calculate_turn_income()
	_dragging = false
	
	shop_popup.hide()
	shop_overlay.mouse_entered.connect(func(): map.ui_hovered = true)
	close_shop_btn.pressed.connect(_close_shop)
	buy_buttons[0].pressed.connect(func(): _buy_card(0))
	buy_buttons[1].pressed.connect(func(): _buy_card(1))
	buy_buttons[2].pressed.connect(func(): _buy_card(2))
	
	improvements_header.hide()
	improvements_list.hide()
	improvements_header.mouse_entered.connect(_on_improvements_entered)
	improvements_header.mouse_exited.connect(_on_improvements_exited)
	
	enemy_control.mouse_entered.connect(_on_enemy_control_entered)
	enemy_control.mouse_exited.connect(_on_enemy_control_exited)
	
func _process(delta: float) -> void:
	_handle_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameManager.go_to_menu()

# ── Caméra ────────────────────────────────────────────────────

func _setup_camera() -> void:
	var map_size: Vector2 = map.get_map_size()
	cam.limit_left   = 0
	cam.limit_top    = 0
	cam.limit_right  = int(map_size.x)
	cam.limit_bottom = int(map_size.y)
	cam.offset       = Vector2.ZERO
	cam.zoom         = Vector2(0.8, 0.8)
	# Centre sur la tuile de départ
	cam.position = Vector2(
		map.START_X * map.TILE_SIZE + map.TILE_SIZE / 2.0,
		map.START_Y * map.TILE_SIZE + map.TILE_SIZE / 2.0
	)

func _handle_camera(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"):  dir.x -= 1
	if Input.is_action_pressed("move_right"): dir.x += 1
	if Input.is_action_pressed("move_up"):    dir.y -= 1
	if Input.is_action_pressed("move_down"):  dir.y += 1


# ── Tuile sélectionnée ────────────────────────────────────────

func _on_tile_selected(tile) -> void:
	if tile == null:
		return
	if tile.is_infested or tile.is_blocked or tile.is_blocked_temp:
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
	_calculate_turn_income()

# ── Game over ─────────────────────────────────────────────────

#func game_over() -> void:
	#await get_tree().create_timer(1.0).timeout
	#GameManager.go_to_menu()
	#AudioManager.crossfade_music(MUSIC_NORMAL)

func _on_turn_changed(_turn: int) -> void:
	_process_turn()
	var avancement_gain: int = max(0, 3 * ModifierManager.avancement_multi - ModifierManager.avancement_minus)
	GameManager.avancement_enemy += avancement_gain
	
func _process_turn() -> void:
	# Utilise turn_income_value déjà calculé — pas de nouveau randi()
	var total: int = 0
	for x in map.MAP_WIDTH:
		for y in map.MAP_HEIGHT:
			var tile = map.get_tile(x, y)
			if tile.is_infested and not tile.is_blocked_temp and not tile.is_blocked:
				var amount: int = tile.rendement + ModifierManager.rendement_bonus
				# La variation aléatoire est calculée une seule fois dans _calculate_turn_income
				total += amount
				tile.show_income(amount)
	
	GameManager.graines += turn_income_value  # ← utilise la valeur affichée
	
	for x in map.MAP_WIDTH:
		for y in map.MAP_HEIGHT:
			var tile = map.get_tile(x, y)
			if tile.is_blocked_temp:
				tile.unblock_temp()
	
	_process_enemy_attack()
	_calculate_turn_income()
	
func _on_graines_changed(value: int) -> void:
	var tween := create_tween()
	tween.tween_method(_update_graines_label, _displayed_graines, value, 0.5)

func _update_graines_label(value: int) -> void:
	_displayed_graines = value
	graines_label.text = str(value)
	
func _on_avancement_changed(value: float) -> void:
	percent_enemy.text = "%.0f%%" % value
	_update_enemy_marker(value)
	_update_music(value)
	
func _reset_game() -> void:
	# Calcule le bonus de graines
	ModifierManager.reset()
	var bonus: int = GameManager.graines
	map.regenerate()
	improvements_header.hide()
	
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
	
	cam.position = Vector2(
		map.START_X * map.TILE_SIZE + map.TILE_SIZE / 2.0,
		map.START_Y * map.TILE_SIZE + map.TILE_SIZE / 2.0
	)
	
	# Réinitialise les variables globales
	GameManager.avancement_enemy = 0.0
	GameManager.graines = bonus
	GameManager.current_turn = 1
	AudioManager.crossfade_music(MUSIC_NORMAL)
	ShopManager.reset_all()

func _on_btn_resets_pressed() -> void:
	_reset_game()

func _process_enemy_attack() -> void:
	var avancement: float = GameManager.avancement_enemy
	if avancement <= 20.0:
		return

	var tranches: int = int((avancement - 20.0) / 10.0)
	var tranchesTemp: int = int((avancement) / 5)
	
	# Calcule le nombre d'attaques de chaque type
	var nb_block_temp: int = 0
	var nb_block: int = 0
	
	# Exemple de logique — adapte les % selon toi
	if randf() * 100.0 < tranches * 30.0:
		nb_block_temp += 1
	if tranches >= 3 and randf() * 100.0 < tranches * 10:
		nb_block_temp += 2
	if randf() * 100.0 < tranches * 8:
		nb_block += 1

	# Récupère toutes les tuiles infestées disponibles (pas déjà attaquées)
	var available_tiles := []
	for x in map.MAP_WIDTH:
		for y in map.MAP_HEIGHT:
			var tile = map.get_tile(x, y)
			if tile.is_infested and not tile.is_blocked and not tile.is_blocked_temp:
				available_tiles.append(tile)

	if available_tiles.is_empty():
		return

	available_tiles.shuffle()

	# Applique d'abord les block temporaires
	var index: int = 0
	for i in nb_block_temp:
		if index >= available_tiles.size():
			break
		available_tiles[index].block_temp()
		index += 1

	# Applique ensuite le block définitif
	# Si une tuile a déjà reçu un block_temp, on la remplace par block définitif
	for i in nb_block:
		if available_tiles.is_empty():
			break
		# Prend la première tuile disponible — si déjà block_temp, block écrase
		var target = available_tiles[0]
		if target.is_blocked_temp:
			target.unblock_temp()
		target.block()
		available_tiles.remove_at(0)

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
	if tile != null:
			if can_infest(tile):
				tile.highlight.color = Color(0.80, 0, 0.80, 0.50)  # violet
			else:
				tile.highlight.color = Color(1, 1, 1, 0.4)
func _on_turn_button_entered() -> void:
	turn_button.texture = TURN_BTN_HOVER
	map.ui_hovered = true
	hovered_button = "next_turn"

func _on_turn_button_exited() -> void:
	turn_button.texture = TURN_BTN_NORMAL
	map.ui_hovered = false
	hovered_button = ""

func _on_reset_button_entered() -> void:
	map.ui_hovered = true
	hovered_button = "reset"
	reset_button.play("hover")


func _on_reset_button_exited() -> void:
	map.ui_hovered = false
	hovered_button = ""
	reset_button.stop()
	reset_button.frame = 0

func _input(event: InputEvent) -> void:
	# Click droit — drag caméra
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			_dragging = true
			_drag_start = get_viewport().get_mouse_position()
			_cam_start = cam.position
		else:
			_dragging = false
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(0.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(-0.1)
		
	# Click gauche — boutons
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		match hovered_button:
			"next_turn":
				GameManager.next_turn()
				_animate_turn_button_click()
			"reset": _open_popup_reset()
			"confirm": _confirm_reset()
			"cancel":  _cancel_reset()

	# Mouvement souris — drag
	if event is InputEventMouseMotion and _dragging:
		var delta := get_viewport().get_mouse_position() - _drag_start
		var new_pos := _cam_start - delta / cam.zoom.x
		var half_w := get_viewport().get_visible_rect().size.x / 2.0 / cam.zoom.x
		var half_h := get_viewport().get_visible_rect().size.y / 2.0 / cam.zoom.y
		cam.position.x = clamp(new_pos.x, cam.limit_left + half_w, cam.limit_right - half_w)
		cam.position.y = clamp(new_pos.y, cam.limit_top + half_h, cam.limit_bottom - half_h)
func _update_enemy_marker(value: float) -> void:
	var track_width: float = progress_track.size.x
	var marker_width: float = enemy_marker.size.x
	# Calcule la position entre 0 et la largeur de la piste
	var target_x: float = (value / 100.0) * (track_width - marker_width)
	# Anime le déplacement
	var tween := create_tween()
	tween.tween_property(enemy_marker, "position:x", target_x, 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
func _open_popup_reset() -> void:
	popup_reset_control.show()
	map.ui_hovered = true  # bloque dès l'ouverture

func _confirm_reset() -> void:
	popup_reset_control.hide()
	map.ui_hovered = false
	hovered_button = ""
	_reset_game()
	_calculate_turn_income()
	_open_shop()

func _cancel_reset() -> void:
	popup_reset_control.hide()
	map.ui_hovered = false  # débloque à la fermeture
	hovered_button = ""

func _animate_turn_button_click() -> void:
	turn_button.texture = TURN_BTN_CLICK
	await get_tree().create_timer(0.15).timeout
	# Revient à l'image hover si la souris est encore dessus, sinon normal
	if hovered_button == "next_turn":
		turn_button.texture = TURN_BTN_HOVER
	else:
		turn_button.texture = TURN_BTN_NORMAL

func _calculate_turn_income() -> void:
	turn_income_value = 0
	for x in map.MAP_WIDTH:
		for y in map.MAP_HEIGHT:
			var tile = map.get_tile(x, y)
			if tile.is_infested:
				turn_income_value += tile.rendement + randi() % 3 + ModifierManager.rendement_bonus
	turn_income.text = "+" + str(turn_income_value)

func _update_music(value: float) -> void:
	if value >= 50.0 and not _music_intense_playing:
		_music_intense_playing = true
		AudioManager.crossfade_music(MUSIC_INTENSE)
	elif value < 50.0 and _music_intense_playing:
		_music_intense_playing = false
		AudioManager.crossfade_music(MUSIC_NORMAL)

func can_infest(tile) -> bool:
	if tile == null:
		return false
	if tile.is_infested or tile.is_blocked or tile.is_blocked_temp:
		return false
	var neighbors: Array = map.get_neighbors(tile.grid_x, tile.grid_y)
	var has_infested_neighbor := false
	for neighbor in neighbors:
		if neighbor.is_infested:
			has_infested_neighbor = true
			break
	if not has_infested_neighbor:
		return false
	if GameManager.graines < tile.get_cout():
		return false
	return true

func _open_shop() -> void:
	ShopManager.pick_random_cards()
	_refresh_shop()
	shop_popup.show()
	map.ui_hovered = true

func _refresh_shop() -> void:
	for i in 3:
		var card = ShopManager.available_cards[i]
		if card == null:
			card_names[i].text = "—"
			card_descs[i].text = ""
			card_costs[i].text = ""
			buy_buttons[i].disabled = true
			continue
		var real_cost: int = card.cost + ShopManager.cost_increase
		card_names[i].text = "[u]" + card.name + "[/u]"
		card_descs[i].text = card.description
		card_costs[i].text = "Cout de l'amélioration : -" + str(real_cost)
		buy_buttons[i].disabled = GameManager.graines < real_cost

func _buy_card(index: int) -> void:
	var card = ShopManager.available_cards[index]
	if card == null:
		return
	if ShopManager.buy_card(card, index):
		_recalculate_all_rendements()
		_refresh_shop()
		improvements_header.show() 

func _close_shop() -> void:
	ShopManager.reset_shop()
	shop_popup.hide()
	map.ui_hovered = false
	GameManager.graines = 50 + ModifierManager.graines_bonus

func _recalculate_all_rendements() -> void:
	for x in map.MAP_WIDTH:
		for y in map.MAP_HEIGHT:
			map.get_tile(x, y).calculate_rendement()
	_calculate_turn_income()

func _zoom(delta: float) -> void:
	var new_zoom: float = clamp(cam.zoom.x + delta, CAM_ZOOM_MIN, CAM_ZOOM_MAX)
	var tween: Tween = create_tween()
	tween.tween_property(cam, "zoom", Vector2(new_zoom, new_zoom), 0.1)

func _on_improvements_entered() -> void:
	map.ui_hovered = true
	_refresh_improvements()
	improvements_list.show()

func _on_improvements_exited() -> void:
	map.ui_hovered = false
	improvements_list.hide()

func _refresh_improvements() -> void:
	# Vide le contenu
	for child in improvements_content.get_children():
		child.queue_free()

	if ShopManager.purchased_cards.is_empty():
		var label := Label.new()
		label.text = "Aucune amélioration"
		improvements_content.add_child(label)
		return

	# Compte les occurrences de chaque carte
	var counts := {}
	for card_id in ShopManager.purchased_cards:
		counts[card_id] = counts.get(card_id, 0) + 1

	for card_id in counts:
		var label := Label.new()
		var count: int = counts[card_id]
		var card_name: String = ShopManager.get_card_name(card_id)
		label.text = card_name + (" x%d" % count if count > 1 else "")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		improvements_content.add_child(label)

func _on_enemy_control_entered() -> void:
	#map.ui_hovered = true
	map.show_custom_tooltip("L'avancement ennemi augmente de %d%% par tour" % int(3 * ModifierManager.avancement_multi - ModifierManager.avancement_minus) + "\n Tous les 10% d'avancement le cout des tuiles et le risque d'évenement négatif augmente")

func _on_enemy_control_exited() -> void:
	#map.ui_hovered = false
	map.hide_tooltip()
