extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	for i in get_overlapping_areas():
		if i.is_in_group("Ball"):
			i.vec.x = 5
			$sound.play()
			
	var y1 = Input.get_action_strength("Spieler1_oben") * 7
	var y2 = Input.get_action_strength("Spieler1_unten") * 7
	var y3 = position.y - y1 + y2
	if y3 > 50 && y3 < 600:
		position.y = position.y - y1 + y2
