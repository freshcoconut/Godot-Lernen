extends CharacterBody2D

enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING
}

const Staende_des_Grundes = [State.IDLE, State.RUNNING, State.LANDING]
const Tempo := 120.0 #200 pixel pro Sekunde
const Tempo_Springen := -300.0
const Grund_Beschleunigung := Tempo / 0.2 # 0.2s for acceleration
const Himmel_Beschleunigung := Tempo / 0.02 # 0.02s for acceleration

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("springen"):
		jump_request_timer.start()
	#松开跳跃键,下落过程中y值必然逐渐变大,只要提前松开,那必然触发velo.y<velocity.y/2,那就提前重置velocity.y
	if event.is_action_released("springen") :
		jump_request_timer.stop()
		if velocity.y < Tempo_Springen / 2:
			velocity.y = Tempo_Springen / 2

func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(default_gravity, delta)
		State.RUNNING:
			move(default_gravity, delta)			
		State.JUMP:
			move(0.0 if is_first_tick else default_gravity, delta)			
		State.FALL:
			move(default_gravity, delta)
		State.LANDING:
			stand(delta)
	
	is_first_tick = false
					 
func move(gravity: float, delta: float) -> void:
	var Richtung := Input.get_axis("sich_nach_links_bewegen", "sich_nach_rechts_bewegen")
	var Beschleunigung = Grund_Beschleunigung if is_on_floor() else Himmel_Beschleunigung
	velocity.x = move_toward(velocity.x, Richtung * Tempo, Beschleunigung * delta)  
	velocity.y += gravity * delta
	
	if ! is_zero_approx(Richtung):
		sprite_2d.flip_h = Richtung < 0
	
	move_and_slide()

func stand(delta: float) -> void:
	var Beschleunigung = Grund_Beschleunigung if is_on_floor() else Himmel_Beschleunigung
	velocity.x = move_toward(velocity.x, 0.0, Beschleunigung * delta)  
	velocity.y += default_gravity * delta
	
	move_and_slide()	

func get_next_state(state: State) -> State:
	var can_jump := is_on_floor() || coyote_timer.time_left > 0
	var should_jump := can_jump && jump_request_timer.time_left > 0
	if should_jump:
		return State.JUMP
	var Richtung := Input.get_axis("sich_nach_links_bewegen", "sich_nach_rechts_bewegen")
	var is_still := is_zero_approx(Richtung) && is_zero_approx(velocity.x)
	match state:
		State.IDLE:
			if !is_on_floor():
				return State.FALL
			if !is_still:
				return State.RUNNING			
		State.RUNNING:
			if !is_on_floor():
				return State.FALL
			if is_still:
				return State.IDLE			
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL			
		State.FALL:
			if is_on_floor():
				return State.LANDING if is_still else State.RUNNING
		State.LANDING:
			if ! animation_player.is_playing():
				return State.IDLE	
	return state
	
func transition_state(von: State, bis: State) -> void:
	if ! von in Staende_des_Grundes && bis in Staende_des_Grundes:
		coyote_timer.stop()
		 
	match bis:
		State.IDLE:
			animation_player.play("idle")
		State.RUNNING:
			animation_player.play("running")
		State.JUMP:
			animation_player.play("jump")
			velocity.y = Tempo_Springen
			coyote_timer.stop()
			jump_request_timer.stop()
		State.FALL:
			animation_player.play("fall")
			if von in Staende_des_Grundes:
				coyote_timer.start()
		State.LANDING:
			animation_player.play("landing")
			
	is_first_tick = true
	
