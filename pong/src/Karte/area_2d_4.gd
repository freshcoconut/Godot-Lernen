extends Area2D

@export var y = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	for i in get_overlapping_areas():
		if i.is_in_group("Ball"):
			i.vec.y = y
