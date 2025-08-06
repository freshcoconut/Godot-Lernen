extends Feind

enum State {
	IDLE,
	WALK,
	RUN,
}

@onready var wand_pruefer: RayCast2D = $Grafiken/WandPruefer
@onready var spieler_pruefer: RayCast2D = $Grafiken/SpielerPruefer
@onready var boden_pruefer: RayCast2D = $Grafiken/BodenPruefer
@onready var calm_down_timer: Timer = $CalmDownTimer

func kann_Spieler_sehen() -> bool:
	if !spieler_pruefer.is_colliding():
		return false
	return spieler_pruefer.get_collider() is Spieler # what is firstly collided

func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(0.0, delta)
		State.WALK:
			move(max_tempo / 3, delta)
		State.RUN:
			if wand_pruefer.is_colliding() || ! boden_pruefer.is_colliding():
				richtung *= -1
			move(max_tempo, delta)
			if kann_Spieler_sehen():
				calm_down_timer.start()

func get_next_state(state: State) -> State:
	if kann_Spieler_sehen():
		return State.RUN
		
	match state:
		State.IDLE:
			if maschine_des_standes.Zeit_des_Standes > 2:
				return State.WALK
		State.WALK:
			if wand_pruefer.is_colliding() || ! boden_pruefer.is_colliding():
				return State.IDLE		
		State.RUN:
			if calm_down_timer.is_stopped():
				return State.WALK
	return state # unveraendert beleiben, wenn state keine von den drei Staenden auswaehlt
	
func transition_state(von: State, bis: State) -> void:
	print("[%s] Boar: %s => %s" %[
		Engine.get_physics_frames(),
		State.keys()[von] if von != -1 else "Start",
		State.keys()[bis],
	])
	
	match bis:
		State.IDLE:
			animation_player.play(&"idle")
			if wand_pruefer.is_colliding():
				richtung *= -1
		State.WALK:
			animation_player.play(&"walk")
			if ! boden_pruefer.is_colliding():
				richtung *= -1
				boden_pruefer.force_raycast_update()
		State.RUN:
			animation_player.play(&"run")
			
func _on_hurt_box_hurt(hitbox: Hit_Box) -> void:
	print("[%s] Boar: How dare you hurt me!" %[Engine.get_physics_frames()])
	statistik.heutige_gesundheit -= 1
	if statistik.heutige_gesundheit == 0:
		queue_free()
