extends HBoxContainer

@export var statistik: Statistik
@onready var gesundheitstab: TextureProgressBar = $V_status/Gesundheitstab
@onready var geloeschter_gesundheitstab: TextureProgressBar = $V_status/Gesundheitstab/Geloeschter_Gesundheitstab
@onready var energiestab: TextureProgressBar = $V_status/Energiestab

func _ready() -> void:
	if not statistik:
		statistik = Spiel.spieler_statistik
	statistik.gesundheit_geaendert.connect(aktualisieren_Gesundheit)
	aktualisieren_Gesundheit(true)
	statistik.energie_geaendert.connect(aktualisieren_Energie)
	aktualisieren_Energie()
	
	tree_exited.connect(func ():
		statistik.gesundheit_geaendert.disconnect(aktualisieren_Gesundheit)
		statistik.energie_geaendert.disconnect(aktualisieren_Energie)
	)

func aktualisieren_Gesundheit(skip_anim := false) -> void:
	var prozent := statistik.heutige_gesundheit / float(statistik.max_Gesundheit)
	gesundheitstab.value = prozent
	
	if skip_anim:
		geloeschter_gesundheitstab.value = prozent
	else:
		create_tween().tween_property(geloeschter_gesundheitstab, ^"value", prozent, 0.3)
	
func aktualisieren_Energie() -> void:
	var prozent := statistik.heutige_energie / float(statistik.max_Energie)
	energiestab.value = prozent
