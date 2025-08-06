class_name  Spieler
extends CharacterBody2D

enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING,
	WALL_SLIDING,
	WALL_JUMP,
	ATTACK_1,
	ATTACK_2,
	ATTACK_3,
}

const Staende_des_Grundes = [State.IDLE, State.RUNNING, State.LANDING, State.ATTACK_1, State.ATTACK_2, State.ATTACK_3]
const Tempo := 120.0 #200 pixel pro Sekunde
const Tempo_Springen := -300.0
const Tempo_Springen_Auf_Wand := Vector2(450, -280)
const Grund_Beschleunigung := Tempo / 0.2 # 0.2s for acceleration
const Himmel_Beschleunigung := Tempo / 0.1 # 0.02s for acceleration

@export var can_combo = false

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false
var is_combo_requested := false

@onready var grafiken: Node2D = $Grafiken
@onready var hand_pruefer: RayCast2D = $Grafiken/HandPruefer
@onready var fuss_pruefer: RayCast2D = $Grafiken/FussPruefer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var maschine_des_standes: Maschine_des_Standes = $Maschine_des_Standes

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"springen"):
		jump_request_timer.start()
	#松开跳跃键,下落过程中y值必然逐渐变大,只要提前松开,那必然触发velo.y<velocity.y/2,那就提前重置velocity.y
	if event.is_action_released(&"springen") :
		jump_request_timer.stop()
		if velocity.y < Tempo_Springen / 2:
			velocity.y = Tempo_Springen / 2
	if event.is_action_pressed(&"Angriff") && can_combo:
		is_combo_requested = true

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
			stand(default_gravity, delta)
		State.WALL_SLIDING:
			move(default_gravity / 12, delta)
			grafiken.scale.x = get_wall_normal().x
		State.WALL_JUMP:
			if maschine_des_standes.Zeit_des_Standes < 0.1:
				stand(0.0 if is_first_tick else default_gravity, delta)
				grafiken.scale.x = get_wall_normal().x
			else:
				move(default_gravity, delta)	
		State.ATTACK_1, State.ATTACK_2, State.ATTACK_3:
			stand(default_gravity, delta)
	
	is_first_tick = false
					 
func move(gravity: float, delta: float) -> void:
	var Richtung := Input.get_axis("sich_nach_links_bewegen", "sich_nach_rechts_bewegen")
	var Beschleunigung = Grund_Beschleunigung if is_on_floor() else Himmel_Beschleunigung
	velocity.x = move_toward(velocity.x, Richtung * Tempo, Beschleunigung * delta)  
	velocity.y += gravity * delta
	
	if ! is_zero_approx(Richtung):
		grafiken.scale.x = -1 if Richtung < 0 else 1
	
	move_and_slide()

func stand(gravity:float, delta: float) -> void:
	var Beschleunigung = Grund_Beschleunigung if is_on_floor() else Himmel_Beschleunigung
	velocity.x = move_toward(velocity.x, 0.0, Beschleunigung * delta)  
	velocity.y += gravity * delta
	
	move_and_slide()	

func can_wall_slide() -> bool:
	return is_on_wall() && hand_pruefer.is_colliding() && fuss_pruefer.is_colliding()

func get_next_state(state: State) -> int:#返回类型为int，因为有可能返回-1
	var can_jump := is_on_floor() || coyote_timer.time_left > 0
	var should_jump := can_jump && jump_request_timer.time_left > 0
	if should_jump:
		return State.JUMP
	
	if state in Staende_des_Grundes && ! is_on_floor():
		return State.FALL
		
	var Richtung := Input.get_axis("sich_nach_links_bewegen", "sich_nach_rechts_bewegen")
	var is_still := is_zero_approx(Richtung) && is_zero_approx(velocity.x)
	match state:
		State.IDLE:
			if Input.is_action_pressed(&"Angriff"):
				return State.ATTACK_1
			if !is_still:
				return State.RUNNING			
		State.RUNNING:
			if Input.is_action_pressed(&"Angriff"):
				return State.ATTACK_1
			if is_still:
				return State.IDLE			
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL			
		State.FALL:
			if is_on_floor():
				return State.LANDING if is_still else State.RUNNING
			if can_wall_slide():
				return State.WALL_SLIDING
		State.LANDING:
			if ! is_still:
				return State.RUNNING
			elif ! animation_player.is_playing():
				return State.IDLE	
		State.WALL_SLIDING:
			if jump_request_timer.time_left > 0 && ! is_first_tick:
				return State.WALL_JUMP
			if is_on_floor():
				return State.IDLE
			elif ! is_on_wall():
				return State.FALL
		State.WALL_JUMP:
			if can_wall_slide() && ! is_first_tick:
				return State.WALL_SLIDING
			if velocity.y >= 0:
				return State.FALL
		State.ATTACK_1:
			if ! animation_player.is_playing():
				return State.ATTACK_2 if is_combo_requested else State.IDLE
		State.ATTACK_2:
			if ! animation_player.is_playing():
				return State.ATTACK_3 if is_combo_requested else State.IDLE
		State.ATTACK_3:
			if ! animation_player.is_playing():
				return State.IDLE
			
	return Maschine_des_Standes.KEEP_CURRENT
	
func transition_state(von: State, bis: State) -> void:
	print("[%s] Spieler: %s => %s" %[
		Engine.get_physics_frames(),
		State.keys()[von] if von != -1 else "Start",
		State.keys()[bis],
	])
	
	if ! von in Staende_des_Grundes && bis in Staende_des_Grundes:
		coyote_timer.stop()
		 
	match bis:
		State.IDLE:
			animation_player.play(&"idle")
		State.RUNNING:
			animation_player.play(&"running")
		State.JUMP:
			animation_player.play(&"jump")
			velocity.y = Tempo_Springen
			coyote_timer.stop()
			jump_request_timer.stop()
		State.FALL:
			animation_player.play(&"fall")
			if von in Staende_des_Grundes:
				coyote_timer.start()
		State.LANDING:
			animation_player.play(&"landing")
		State.WALL_SLIDING:
			animation_player.play(&"wall_sliding")
		State.WALL_JUMP:
			animation_player.play(&"jump")
			velocity = Tempo_Springen_Auf_Wand
			velocity.x *= get_wall_normal().x
			jump_request_timer.stop()
		State.ATTACK_1:
			animation_player.play(&"attack_1")
			is_combo_requested = false
		State.ATTACK_2:
			animation_player.play(&"attack_2")
			is_combo_requested = false
		State.ATTACK_3:
			animation_player.play(&"attack_3")
			is_combo_requested = false
	
	if bis == State.WALL_JUMP:
		Engine.time_scale = 0.3
	if von == State.WALL_JUMP:
		Engine.time_scale = 1.0
	
	is_first_tick = true
	
