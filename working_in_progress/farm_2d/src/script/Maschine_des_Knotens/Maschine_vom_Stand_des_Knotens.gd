class_name Maschine_vom_Stand_des_Knotens
extends Node

@export var anfaenglicher_stand_des_knotens: Stand_des_Knotens

var staende_des_knotens: Dictionary = {}
var aktueller_stand_des_knotens: Stand_des_Knotens
var name_vom_aktuellen_stand_des_knotens: String

func _ready() -> void:
	for kind in get_children():
		if kind is Stand_des_Knotens:
			staende_des_knotens[kind.name.to_lower()] = kind
			kind.uebergang_vom_stand_des_knotens.connect(uebergang_zu)
			
	if anfaenglicher_stand_des_knotens:
		anfaenglicher_stand_des_knotens._im_eingang()
		aktueller_stand_des_knotens = anfaenglicher_stand_des_knotens

func _process(delta: float) -> void: #
	if aktueller_stand_des_knotens:
		aktueller_stand_des_knotens._on_process(delta)
	
func _physics_process(delta: float) -> void:#教程中的“_on_process()”和“_on_physics_process()”是新的函数名称
	if aktueller_stand_des_knotens:
		aktueller_stand_des_knotens._on_physics_process(delta)
		aktueller_stand_des_knotens._im_naechsten_uebergang()
		
func uebergang_zu(name_vom_stand_des_knotens: String) -> void:
	if name_vom_stand_des_knotens == aktueller_stand_des_knotens.name.to_lower():
		return # in dieselbem Stand bleiben soll
	
	var neuer_stand_des_knotens: Stand_des_Knotens = staende_des_knotens.get(name_vom_stand_des_knotens.to_lower())
	
	if ! neuer_stand_des_knotens:
		return # Leider haben wir jetzt keinen neuen Stand des Knotens.
	
	# letzer Stand des Knotens
	if aktueller_stand_des_knotens:
		aktueller_stand_des_knotens._im_ausgang()

	neuer_stand_des_knotens._im_eingang()
	
	aktueller_stand_des_knotens = neuer_stand_des_knotens
	name_vom_aktuellen_stand_des_knotens = aktueller_stand_des_knotens.name.to_lower()
	
	print("aktueller Stand des Knotens: ", name_vom_aktuellen_stand_des_knotens)
