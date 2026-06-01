extends Node

var rendement_multi:   float
var cout_multi:        float
var avancement_multi:  float
var rendement_bonus:   int
var graines_bonus:     int
var avancement_minus:  int
var multi_argile:      float
var multi_limon:       float
var multi_terre_groie: float

func _ready() -> void:
	reset()

func reset() -> void:
	rendement_multi  = 1.0
	cout_multi       = 1.0
	avancement_multi = 1.0
	rendement_bonus  = 0
	graines_bonus    = 0
	avancement_minus = 0
	multi_argile      = 1.0
	multi_limon       = 1.0
	multi_terre_groie = 1.0
