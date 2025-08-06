extends HBoxContainer

@export var statistik: Statistik

@onready var gesundheitanzeige: TextureProgressBar = $Gesundheitanzeige

func _ready() -> void:
	statistik.gesundheit_geaendert.connect(aktualisieren_Gesundheit)
	aktualisieren_Gesundheit()

func aktualisieren_Gesundheit() -> void:
	var prozent := statistik.heutige_gesundheit / float(statistik.max_Gesundheit)
	gesundheitanzeige.value = prozent
