extends Area3D
class_name Checkpoint

var is_activated: bool = false

@export var ist_der_endliche_checkpoint: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D && !is_activated:
		$AnimationPlayer.play("aktivieren")
		is_activated = true
		SpielVerwalter.instanz.activated_checkpoints.append(self)
		
		if ist_der_endliche_checkpoint:
			SpielVerwalter.instanz.gewinnen_spiel()
			SpielVerwalter.instanz.ist_spiel_beendet = true
