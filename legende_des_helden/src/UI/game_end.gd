extends Control

const LINES := [
	"野猪王被做成了烤串",
	"村民们熬过了这次饥荒",
	"然而剩下的野猪不会放过你",
	"野猪小队永远会在树丛中埋伏你",
]

var current_line := -1
var tween: Tween

@onready var label: Label = $Label
@onready var victory_audio: AudioStreamPlayer = $Victory_Audio

func _ready() -> void:
	show_line(0)
	victory_audio.play()
	
func _input(event: InputEvent) -> void:	
	if tween.is_running():
		return
	
	if event is InputEventKey || event is InputEventMouseButton || event is InputEventJoypadButton:
		if event.is_pressed() && ! event.is_echo():
			if current_line + 1 < LINES.size():
				show_line(current_line + 1)
			else:
				Spiel.back_to_title()

func show_line(linie: int) -> void:
	current_line = linie
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	if linie > 0:
		tween.tween_property(label, ^"modulate:a", 0, 1) # Es dauert eine Sekunde
	else: # linie = 0
		label.modulate.a = 0
		
	tween.tween_callback(label.set_text.bind(LINES[linie]))
	tween.tween_property(label, ^"modulate:a", 1, 1) # Es dauert eine Sekunde


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
