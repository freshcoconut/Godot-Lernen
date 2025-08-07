class_name  Teleporter
extends Interactable

@export_file("*.tscn") var path: String

@export var entry_point: String

func interact() -> void:
	Spiel.szene_veraendern(path, {entry_point=entry_point})
