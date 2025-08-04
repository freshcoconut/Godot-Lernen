class_name Maschine_des_Standes
extends Node

var Zeit_des_Standes: float

var heutiger_Stand: int = -1:
	set(v):
		owner.transition_state(heutiger_Stand, v) # the root node in this scene, that is the node Spieler, which should define the function transition_state
		heutiger_Stand = v
		Zeit_des_Standes = 0

func _ready() -> void:
	await owner.ready # first: children node will be ready; second: root node then will be ready
	heutiger_Stand = 0

func _physics_process(delta: float) -> void:
	while true:
		var naechst := owner.get_next_state(heutiger_Stand) as int
		if heutiger_Stand == naechst:
			break
		heutiger_Stand = naechst
	#Am Ende ist der Stand staendig
	owner.tick_physics(heutiger_Stand, delta)
	Zeit_des_Standes += delta
