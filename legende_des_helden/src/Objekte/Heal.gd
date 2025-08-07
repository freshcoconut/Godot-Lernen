class_name  Heal
extends Interactable

func interact() -> void:
	print("[%s] Interact with %s! Medicine!" %[Engine.get_physics_frames(), name])
	interacted.emit()
	Spiel.spieler_statistik.heutige_gesundheit = Spiel.spieler_statistik.max_Gesundheit
	Spiel.spieler_statistik.heutige_energie = Spiel.spieler_statistik.max_Energie
