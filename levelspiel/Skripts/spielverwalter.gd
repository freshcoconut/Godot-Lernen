extends Node3D
class_name SpielVerwalter

static var instanz: SpielVerwalter = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if instanz == null:
		instanz = self
	else:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("verlassen_das_spiel"):
		get_tree().quit()


func spieler_wiederbeleben(body: Node3D) -> void:
	if body is CharacterBody3D:
		get_tree().reload_current_scene()
	pass # Replace with function body.

func sammeln_ding(typ_ding) -> void:
	print(typ_ding)
	
