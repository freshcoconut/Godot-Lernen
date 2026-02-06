extends Node3D
class_name SpielVerwalter

# 单例模式：只能存在一个SpielVerwalter的实例
static var instanz: SpielVerwalter = self

@export var erfasste_dinge: Dictionary[String, int] = {
	"DIAMOND": 0,
	"COIN": 0,
	"CHERRY": 0,
}

@export var item_labels: Dictionary[String, Label]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if instanz == null:
		instanz = self
	else:
		queue_free()

	print("DIAMOND: ", erfasste_dinge["DIAMOND"], "; ","COIN: ", erfasste_dinge["COIN"], "; ", "CHERRY: ", erfasste_dinge["CHERRY"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("verlassen_das_spiel"):
		get_tree().quit()


func spieler_wiederbeleben(body: Node3D) -> void:
	if body is CharacterBody3D:
		get_tree().call_deferred("reload_current_scene")
	pass # Replace with function body.

func sammeln_ding(typ_ding: String) -> void:
	erfasste_dinge[typ_ding] += 1
	print(typ_ding)
	print("DIAMOND: ", erfasste_dinge["DIAMOND"], "; ","COIN: ", erfasste_dinge["COIN"], "; ", "CHERRY: ", erfasste_dinge["CHERRY"])
	item_labels[typ_ding].text = str(erfasste_dinge[typ_ding])
	
