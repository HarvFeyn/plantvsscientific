extends Node

var cost_increase: int = 0
var purchased_cards: Array = []

class Card:
	var id: String
	var name: String
	var description: String
	var cost: int
	var effect: Callable
	
	func _init(p_id, p_name, p_desc, p_cost, p_effect):
		id          = p_id
		name        = p_name
		description = p_desc
		cost        = p_cost
		effect      = p_effect

var all_cards: Array = []
var available_cards: Array = []  # les 3 cartes du tour

func _ready() -> void:
	_init_cards()

func _init_cards() -> void:
	all_cards = [
		Card.new("rendement_up",   "Production maximale",       "Toutes les tuiles produisent 10% de plus (multiplicatif)",      150,  func(): ModifierManager.rendement_multi  *= 1.1),
		Card.new("cout_down", "Croissance", "Les tuiles coûtent 10% moins cher (multiplicatif)", 150, func(): ModifierManager.cout_multi *= 0.9),
		Card.new("avancement_slow","Épines", "Diminue de 1% l'avancée de la connaissance humaine par tour",  600,  func(): ModifierManager.avancement_minus  += 1),
		Card.new("rendement_bonus","Adaptation",    "Chaque tuile produit 1 graines de plus",        200,  func(): ModifierManager.rendement_bonus   += 2),
		Card.new("graines_bonus",  "Stock de graine",          "Reçois 50 graines de plus à la sortie de l'hibernation",               200,  func(): ModifierManager.graines_bonus += 50),
		Card.new("spe_argile", "Spécialiste Argile","Argile +20% de production, Limon et Terre de Groie -10% de production", 100, func(): 
		ModifierManager.multi_argile      *= 1.2
		ModifierManager.multi_limon       *= 0.9
		ModifierManager.multi_terre_groie *= 0.9
		),
		Card.new("spe_limon", "Spécialiste Limon", "Limon +25% de production, Argile et Terre de Groie -10% de production", 100, func():
		ModifierManager.multi_limon       *= 1.25
		ModifierManager.multi_argile      *= 0.9
		ModifierManager.multi_terre_groie *= 0.9
		),
		Card.new("spe_terre_groie", "Spécialiste Terre de Groie", "Terre de Groie +15% de production, Argile et Limon -10% de production", 100, func():
		ModifierManager.multi_terre_groie *= 1.15
		ModifierManager.multi_argile      *= 0.9
		ModifierManager.multi_limon       *= 0.9
		),
		Card.new("combo_argile", "Affinité Argile","Chaque tuile d'argile gagne +3 de production de base pour chaque autre tuile d'argile adjacente en votre possession", 250, func():  ModifierManager.combo_argile += 3),
		Card.new("combo_limon", "Affinité Limon", "Chaque tuile de limon gagne +4 de production de base pour chaque autre tuile de limon adjacente en votre possession", 250, func(): ModifierManager.combo_limon += 4),
		Card.new("combo_terre_groie", "Affinité Terre de Groie", "Chaque tuile de terre de groie gagne +2 de production de base pour chaque autre tuile de terre de groie adjacente en votre possession", 250, func(): ModifierManager.combo_terre_groie += 2),
		Card.new("jump_tile", "Graine planante", "Vous pouvez répandre vos graines à une case de distance de plus", 500, func(): ModifierManager.jump_tile = true),
		Card.new("resi", "Resilience", "Vous avez +20% de chance que la case reste infestée après le passage des humains", 200, func(): ModifierManager.resi += 0.2),
	]

func buy_card(card: Card, index: int) -> bool:
	if GameManager.graines < card.cost + cost_increase:
		return false
	GameManager.graines -= card.cost + cost_increase
	card.effect.call()
	purchased_cards.append(card.id)  # ← enregistre l'achat
	cost_increase += 50
	_replace_card(index)
	return true

func pick_random_cards() -> void:
	var shuffled := all_cards.filter(_is_card_available).duplicate()
	shuffled.shuffle()
	available_cards = shuffled.slice(0, 3)

func shuffle_shop() -> bool:
	if GameManager.graines < 100:
		return false
	GameManager.graines -= 100
	available_cards = []
	pick_random_cards()
	return true

func _replace_card(index: int) -> void:
	var current_ids := []
	for c in available_cards:
		if c != null:
			current_ids.append(c.id)
	
	var candidates := all_cards.filter(_is_card_available).filter(
		func(c): return not c.id in current_ids
	)
	
	if candidates.is_empty():
		available_cards[index] = null
		return
	
	candidates.shuffle()
	available_cards[index] = candidates[0]

func _is_card_available(card: Card) -> bool:
	match card.id:
		"avancement_slow":
			return ModifierManager.avancement_minus < 2
		"jump_tile":
			return !ModifierManager.jump_tile
		"resi":
			return ModifierManager.resi < 1.0
	return true

func reset_shop() -> void:
	cost_increase = 0
	available_cards = []

func get_card_name(id: String) -> String:
	for card in all_cards:
		if card.id == id:
			return card.name
	return id
	
func reset_all() -> void:
	purchased_cards = []
	reset_shop()
