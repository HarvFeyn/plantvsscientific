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
		Card.new("rendement_up",   "Production maximale",       "Toutes les tuiles produisent 20% de plus (multiplicatif)",      300,  func(): ModifierManager.rendement_multi  *= 1.2),
		Card.new("cout_down", "Développement", "Les tuiles coûtent 20% moins cher (multiplicatif)", 300, func(): ModifierManager.cout_multi *= 0.8),
		Card.new("avancement_slow","Ralentir les humains", "Diminue de 1% l'avancée de la connaissance humaine par tour",  600,  func(): ModifierManager.avancement_minus  += 1),
		Card.new("rendement_bonus","Adaptation",    "Chaque tuile produit 1 graines de plus",        250,  func(): ModifierManager.rendement_bonus   += 2),
		Card.new("graines_bonus",  "Stock de graine",          "Reçois 50 graines à la sortie de l'hibernation",               250,  func(): ModifierManager.graines_bonus += 50),
		Card.new("spe_argile", "Spécialiste Argile","Argile +40% de production, Limon et Terre de Groie -20% de production", 200, func(): 
		ModifierManager.multi_argile      *= 1.4
		ModifierManager.multi_limon       *= 0.8
		ModifierManager.multi_terre_groie *= 0.8
		),
		Card.new("spe_limon", "Spécialiste Limon", "Limon +50% de production, Argile et Terre de Groie -20% de production", 200, func():
		ModifierManager.multi_limon       *= 1.5
		ModifierManager.multi_argile      *= 0.8
		ModifierManager.multi_terre_groie *= 0.8
		),
		Card.new("spe_terre_groie", "Spécialiste Terre de Groie", "Terre de Groie +30% de production, Argile et Limon -20% de production", 200, func():
		ModifierManager.multi_terre_groie *= 1.3
		ModifierManager.multi_argile      *= 0.8
		ModifierManager.multi_limon       *= 0.8
		),
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
