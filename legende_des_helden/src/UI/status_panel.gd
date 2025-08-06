extends HBoxContainer

@export var statistik: Statistik
@onready var gesundheitstab: TextureProgressBar = $V_status/Gesundheitstab
@onready var geloeschter_gesundheitstab: TextureProgressBar = $V_status/Gesundheitstab/Geloeschter_Gesundheitstab
@onready var energiestab: TextureProgressBar = $V_status/Energiestab

func _ready() -> void:
	statistik.gesundheit_geaendert.connect(aktualisieren_Gesundheit)
	aktualisieren_Gesundheit()
	statistik.energie_geaendert.connect(aktualisieren_Energie)
	aktualisieren_Energie()

func aktualisieren_Gesundheit() -> void:
	var prozent := statistik.heutige_gesundheit / float(statistik.max_Gesundheit)
	gesundheitstab.value = prozent
	
	create_tween().tween_property(geloeschter_gesundheitstab, ^"value", prozent, 0.3)
	
func aktualisieren_Energie() -> void:
	var prozent := statistik.heutige_energie / float(statistik.max_Energie)
	energiestab.value = prozent
