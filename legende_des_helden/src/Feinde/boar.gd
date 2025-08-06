extends Feind

enum State {
	IDLE,
	WALK,
	RUN,
	HURT,
	TOT,
}

const KNOCKBACK_AMOUNT := 512.0

var pending_damage: Schaden #待处理的伤害

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
		State.IDLE, State.HURT, State.TOT:
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
	if statistik.heutige_gesundheit == 0:
		return State.TOT
	
	if pending_damage: #pending_damage > 0
		return State.HURT
		
	match state:
		State.IDLE:
			if kann_Spieler_sehen():
				return State.RUN
			if maschine_des_standes.Zeit_des_Standes > 2:
				return State.WALK
		State.WALK:
			if kann_Spieler_sehen():
				return State.RUN
			if wand_pruefer.is_colliding() || ! boden_pruefer.is_colliding():
				return State.IDLE		
		State.RUN:
			if ! kann_Spieler_sehen() && calm_down_timer.is_stopped():
				return State.WALK
		State.HURT:
			if ! animation_player.is_playing():
				return State.RUN
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
		State.HURT:
			animation_player.play(&"hit")
			
			#Die Gesundheit wird verringert.
			statistik.heutige_gesundheit -= pending_damage.menge
			
			#被击退
			var dir := pending_damage.quelle.global_position.direction_to(self.global_position)
			self.velocity = dir * KNOCKBACK_AMOUNT
			if dir.x > 0: # nach rechts
				richtung = Richtung.LINKS
			else:
				richtung = Richtung.RECHTS
				
			pending_damage = null
		State.TOT:
			animation_player.play(&"tot")
				
func _on_hurt_box_hurt(hitbox: Hit_Box) -> void:
	print("[%s] Boar: %s! how dare you hurt me!" %[Engine.get_physics_frames(), hitbox.owner.name])
	pending_damage = Schaden.new()
	pending_damage.menge = 1
	pending_damage.quelle = hitbox.ownerd
	if statistik.heutige_gesundheit == 0:
		queue_free()
