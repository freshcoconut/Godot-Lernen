extends Node

@onready var spieler_statistik: Statistik = $Spieler_Statistik

func szene_veraendern(path: String, entry_point: String) -> void:
	var tree := get_tree()
	tree.change_scene_to_file(path)
	await tree.tree_changed
	
	for node in tree.get_nodes_in_group("entry_points"):
		if node.name == entry_point:
			tree.current_scene.spieler_aktualisieren(node.global_position, node.richtung)
			break
