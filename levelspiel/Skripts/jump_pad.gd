extends Area3D

@export var tempo_von_springen: float = 12
@export var particle_system: GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.velocity.y = tempo_von_springen
		particle_system.restart()
