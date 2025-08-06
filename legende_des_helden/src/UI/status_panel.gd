extends HBoxContainer

@export var statistik: Statistik

@onready var gesundheitstab: TextureProgressBar = $Gesundheitstab
@onready var geloeschter_gesundheitstab: TextureProgressBar = $Gesundheitstab/Geloeschter_Gesundheitstab

func _ready() -> void:
	statistik.gesundheit_geaendert.connect(aktualisieren_Gesundheit)
	aktualisieren_Gesundheit()

func aktualisieren_Gesundheit() -> void:
	var prozent := statistik.heutige_gesundheit / float(statistik.max_Gesundheit)
	gesundheitstab.value = prozent
	
	create_tween().tween_property(geloeschter_gesundheitstab, ^"value", prozent, 0.3)
