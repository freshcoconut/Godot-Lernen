extends Control

@onready var new_game: Button = $V/NewGame
@onready var v: VBoxContainer = $V

func _ready() -> void:
	new_game.grab_focus()
	
	for botton: Button in v.get_children():
		botton.mouse_entered.connect(botton.grab_focus)

func _on_new_game_pressed() -> void:
	Spiel.neu_spiel()

func _on_load_game_pressed() -> void:
	Spiel.spiel_laden()

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func to_dict() -> Dictionary:
	var betraege_lebendige_feinde := []
	
	for node in get_tree().get_nodes_in_group("feinde"):
		var path := get_path_to(node) as String
		betraege_lebendige_feinde.append(path)
		
	return {
		lebendige_feinde=betraege_lebendige_feinde
	}
	
func from_dict(dict: Dictionary) -> void:
	for node in get_tree().get_nodes_in_group("feinde"):
		var path := get_path_to(node) as String
		if !path in dict.lebendige_feinde:
			node.queue_free()
