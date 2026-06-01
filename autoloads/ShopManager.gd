extends Node

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
		Card.new("rendement_up",   "+20% rendement",       "Toutes les tuiles produisent 20% de plus",      300,  func(): ModifierManager.rendement_multi  += 0.2),
		Card.new("cout_down",      "-20% coût",            "Les tuiles coûtent 20% moins cher",             400,  func(): ModifierManager.cout_multi        -= 0.2),
		Card.new("avancement_slow","Ennemi -25%",          "L'ennemi avance 25% moins vite",                500,  func(): ModifierManager.avancement_multi  -= 0.25),
		Card.new("rendement_bonus","+2 rendement fixe",    "Chaque tuile produit 2 graines de plus",        350,  func(): ModifierManager.rendement_bonus   += 2),
		Card.new("graines_bonus",  "+50 graines",          "Reçois 50 graines immédiatement",               200,  func(): GameManager.graines               += 50),
	]

func pick_random_cards() -> void:
	var shuffled := all_cards.duplicate()
	shuffled.shuffle()
	available_cards = shuffled.slice(0, 3)

func buy_card(card: Card) -> bool:
	if GameManager.graines < card.cost:
		return false
	GameManager.graines -= card.cost
	card.effect.call()
	return true
