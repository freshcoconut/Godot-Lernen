extends Node

# Name der Szene => {
#	lebendige_feinde => [Weg der Feinde]
#}
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
	
	var alter_name := tree.current_scene.scene_file_path.get_file().get_basename()
	staende_der_welt[alter_name] = tree.current_scene.to_dict()
	
	tree.change_scene_to_file(path)
	await tree.tree_changed
	
	var neuer_name := tree.current_scene.scene_file_path.get_file().get_basename()

	if neuer_name in staende_der_welt:
		tree.current_scene.from_dict(staende_der_welt[neuer_name])
	
	for node in tree.get_nodes_in_group("entry_points"):
		if node.name == entry_point:
			tree.current_scene.spieler_aktualisieren(node.global_position, node.richtung)
			break
			
	tree.paused = false
	
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0, 0.2)
