extends Node

var staende_der_welt := {}

@onready var spieler_statistik: Statistik = $Spieler_Statistik
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color.a = 0

func szene_veraendern(path: String, entry_point: String) -> void:
	var tree := get_tree()
	tree.paused = true
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 1, 0.2)
	await tween.finished
	
	tree.change_scene_to_file(path)
	await tree.tree_changed
	
	for node in tree.get_nodes_in_group("entry_points"):
		if node.name == entry_point:
			tree.current_scene.spieler_aktualisieren(node.global_position, node.richtung)
			break
			
	tree.paused = false
	
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0, 0.2)
