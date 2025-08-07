extends Node

signal camera_should_shake(amount: float)

const SAVE_PATH := "user://data.sav"

# Name der Szene => {
#	lebendige_feinde => [Weg der Feinde]
#}
var staende_der_welt := {}

@onready var spieler_statistik: Statistik = $Spieler_Statistik
@onready var color_rect: ColorRect = $ColorRect
@onready var standard_spieler_statistik := spieler_statistik.to_dict()

func _ready() -> void:
	color_rect.color.a = 0

func szene_veraendern(path: String, params: Dictionary) -> void:
	var tree := get_tree()
	tree.paused = true
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 1, 0.2)
	await tween.finished
	
	var alter_name := tree.current_scene.scene_file_path.get_file().get_basename()
	staende_der_welt[alter_name] = tree.current_scene.to_dict()
	
	tree.change_scene_to_file(path)
	if "init" in params:
		params.init.call()
	await tree.tree_changed
	
	var neuer_name := tree.current_scene.scene_file_path.get_file().get_basename()

	if neuer_name in staende_der_welt:
		tree.current_scene.from_dict(staende_der_welt[neuer_name])
		
	if "entry_point" in params:
		for node in tree.get_nodes_in_group("entry_points"):
			if node.name == params.entry_point:
				tree.current_scene.spieler_aktualisieren(node.global_position, node.richtung)
				break
	if "title_position" in params && "title_richtung" in params:
		tree.current_scene.spieler_aktualisieren(params.title_position, params.title_richtung)
			
	tree.paused = false
	
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 0, 0.2)
	
func spiel_speichern() -> void:
	var szene := get_tree().current_scene
	var name_von_szene := szene.scene_file_path.get_file().get_basename()
	staende_der_welt[name_von_szene] = szene.to_dict()
	var data := {
		title_staende_der_welt=staende_der_welt,
		title_spieler_statistik=spieler_statistik.to_dict(),
		title_szene=szene.scene_file_path,
		title_spieler= {
			title_richtung=szene.spieler.richtung,
			title_position={
				x=szene.spieler.global_position.x,
				y=szene.spieler.global_position.y,
			},
		}
	}
	var json := JSON.stringify(data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE) 
	if not file: # null, scheitern
		return

	file.store_string(json)

func spiel_laden() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file: # null, scheitern
		return
	
	var json := file.get_as_text()
	var data := JSON.parse_string(json) as Dictionary
	
	szene_veraendern(data.title_szene, {
		title_richtung = data.title_spieler.title_richtung,
		title_position = Vector2(
			data.title_spieler.title_position.x,
			data.title_spieler.title_position.y
		),
		init = func ():
			staende_der_welt = data.title_staende_der_welt
			spieler_statistik.from_dict(data.title_spieler_statistik)
	})
	
func neu_spiel() -> void:
	szene_veraendern("res://Welt/Wald.tscn", {
		init = func ():
			staende_der_welt = {}
			spieler_statistik.from_dict(standard_spieler_statistik)
	})

func back_to_title() -> void:
	szene_veraendern("res://UI/title_screen.tscn", {})	

func shake_camera(amount: float) -> void:
	camera_should_shake.emit(amount)
	
