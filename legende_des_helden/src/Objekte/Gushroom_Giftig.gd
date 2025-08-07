class_name  Gushroom_Giftig
extends Interactable

func interact() -> void:
	print("[%s] Interact with %s! Poison!" %[Engine.get_physics_frames(), name])
	interacted.emit()
	Spiel.spieler_statistik.heutige_gesundheit = 1.0
	Spiel.spieler_statistik.heutige_energie = 1.0
