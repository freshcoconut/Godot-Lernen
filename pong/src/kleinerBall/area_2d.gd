extends Area2D

var vec:Vector2 = Vector2(1, 1)
var init_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_to_group("Ball")
	init_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame. 
func _process(delta: float) -> void:
	position = position + vec
	
func reset_ball():
	if vec.x > 0:
		PunkteBerechnen.Punkt1 = PunkteBerechnen.Punkt1 + 1
		vec.x = 1
		if vec.y > 0:
			vec.y = 1
		else:
			vec.y = -1
	else:
		PunkteBerechnen.Punkt2 = PunkteBerechnen.Punkt2 + 1
		vec.x = -1
		if vec.y > 0:
			vec.y = 1
		else:
			vec.y = -1
	position = init_position
