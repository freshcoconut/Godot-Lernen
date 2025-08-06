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
	HURT,
	TOT,
	SLIDING_START,
	SLIDING_LOOP,
	SLIDING_END,
}

const Staende_des_Grundes = [State.IDLE, State.RUNNING, State.LANDING, State.ATTACK_1, State.ATTACK_2, State.ATTACK_3]
const Tempo := 120.0 #120 pixel pro Sekunde
const Tempo_Springen := -300.0
const Tempo_Springen_Auf_Wand := Vector2(450, -280)
const Grund_Beschleunigung := Tempo / 0.2 # 0.2s for acceleration
const Himmel_Beschleunigung := Tempo / 0.1 # 0.02s for acceleration
const KNOCKBACK_AMOUNT := 512.0
const SLIDING_DURATION := 0.3
const SLIDING_SPEED := 240.0
const SLIDING_ENERGIE := 2.0
const ANGRIFF_ENERGIE := 0.5
const SPRINGEN_ENERGIE := 1.0
const LANDING_HEIGHT := 100.0

@export var can_combo = false

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false
var is_combo_requested := false
var pending_damage: Schaden
var fall_from_y: float
var interacting_with: Array[Interactable]

@onready var grafiken: Node2D = $Grafiken
@onready var hand_pruefer: RayCast2D = $Grafiken/HandPruefer
@onready var fuss_pruefer: RayCast2D = $Grafiken/FussPruefer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var maschine_des_standes: Maschine_des_Standes = $Maschine_des_Standes
@onready var statistik: Statistik = $Statistik
@onready var unschlagbar_timer: Timer = $UnschlagbarTimer
@onready var slide_request_timer: Timer = $SlideRequestTimer
@onready var can_attack := false
@onready var should_attack := false
@onready var can_jump := false
@onready var should_jump := false
@onready var interaction_icon: AnimatedSprite2D = $InteractionIcon

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"springen"):
		jump_request_timer.start()
	#松开跳跃键,下落过程中y值必然逐渐变大,只要提前松开,那必然触发velo.y<velocity.y/2,那就提前重置velocity.y
	if event.is_action_released(&"springen") :
		jump_request_timer.stop()
		if velocity.y < Tempo_Springen / 2:
			velocity.y = Tempo_Springen / 2
	if can_attack && can_combo:
		is_combo_requested = true
	if event.is_action_pressed(&"slide"):
		slide_request_timer.start()
	if event.is_action_pressed(&"interact") && interacting_with: # interacting_with != null
		interacting_with.back().interact()

func tick_physics(state: State, delta: float) -> void:
	interaction_icon.visible = ! interacting_with.is_empty()
	
	if unschlagbar_timer.time_left > 0:
		grafiken.modulate.a = sin(Time.get_ticks_msec() / 20) * 0.5 + 0.5
	else:
		grafiken.modulate.a = 1
		
	can_attack = statistik.heutige_energie >= ANGRIFF_ENERGIE
	should_attack = statistik.heutige_energie >= ANGRIFF_ENERGIE && Input.is_action_just_pressed(&"Angriff")
	can_jump = statistik.heutige_energie >= SPRINGEN_ENERGIE && (is_on_floor() || coyote_timer.time_left > 0)
	should_jump = can_jump && jump_request_timer.time_left > 0
		
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
		State.HURT, State.TOT:
			stand(default_gravity, delta)
		State.SLIDING_END:
			stand(default_gravity, delta)
		State.SLIDING_START, State.SLIDING_LOOP:
			slide(delta)
	
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

func slide(delta: float) -> void:
	velocity.x = grafiken.scale.x * SLIDING_SPEED
	velocity.y += default_gravity * delta
	
	move_and_slide()

func tot() -> void:
	get_tree().reload_current_scene()
	print("[%s] Spieler: I am back!" %[Engine.get_physics_frames()])	
	
func anmelden_interactable(v: Interactable) -> void:
	if maschine_des_standes.heutiger_Stand == State.TOT: #死亡状态下不接受新的交互
		return
	if v in interacting_with:
		return
	interacting_with.append(v)
	
func abmelden_interactable(v: Interactable) -> void:
	interacting_with.erase(v)
	

func can_wall_slide() -> bool:
	return is_on_wall() && hand_pruefer.is_colliding() && fuss_pruefer.is_colliding()
	
func should_slide() -> bool:
	if slide_request_timer.is_stopped(): #just: 只按一下
		return false
	if statistik.heutige_energie < SLIDING_ENERGIE:
		return false;
	return ! fuss_pruefer.is_colliding()

func get_next_state(state: State) -> int: #返回类型为int，因为有可能返回-1
	if statistik.heutige_gesundheit == 0:
		return Maschine_des_Standes.KEEP_CURRENT if state == State.TOT else State.TOT
	
	if pending_damage: #pending_damage > 0
		return State.HURT
		
	var can_jump := statistik.heutige_energie >= SPRINGEN_ENERGIE && (is_on_floor() || coyote_timer.time_left > 0)
	var should_jump := can_jump && jump_request_timer.time_left > 0
	if should_jump:
		return State.JUMP
	
	if state in Staende_des_Grundes && ! is_on_floor():
		return State.FALL
		
	var Richtung := Input.get_axis("sich_nach_links_bewegen", "sich_nach_rechts_bewegen")
	var is_still := is_zero_approx(Richtung) && is_zero_approx(velocity.x)
	match state:
		State.IDLE:
			if should_attack:
				return State.ATTACK_1
			if should_slide():
				return State.SLIDING_START
			if !is_still:
				return State.RUNNING			
		State.RUNNING:
			if should_attack:
				return State.ATTACK_1
			if should_slide():
				return State.SLIDING_START
			if is_still:
				return State.IDLE			
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL			
		State.FALL:
			if is_on_floor():
				var height = global_position.y - fall_from_y
				return State.LANDING if height >= LANDING_HEIGHT else State.RUNNING
			if can_wall_slide():
				return State.WALL_SLIDING
		State.LANDING:
			if ! animation_player.is_playing():
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
		State.HURT:
			if ! animation_player.is_playing():
				return State.IDLE
		State.SLIDING_START:
			if ! animation_player.is_playing():
				return State.SLIDING_LOOP
		State.SLIDING_LOOP:
			if maschine_des_standes.Zeit_des_Standes > SLIDING_DURATION || is_on_wall():
				return State.SLIDING_END
		State.SLIDING_END:
			if ! animation_player.is_playing():
				return State.IDLE
			
	return Maschine_des_Standes.KEEP_CURRENT
	
func transition_state(von: State, bis: State) -> void:
	#print("[%s] Spieler: %s => %s" %[
		#Engine.get_physics_frames(),
		#State.keys()[von] if von != -1 else "Start",
		#State.keys()[bis],
	#])
	
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
			statistik.heutige_energie -= SPRINGEN_ENERGIE
		State.FALL:
			animation_player.play(&"fall")
			if von in Staende_des_Grundes:
				coyote_timer.start()
			fall_from_y = global_position.y
		State.LANDING:
			animation_player.play(&"landing")
		State.WALL_SLIDING:
			animation_player.play(&"wall_sliding")
		State.WALL_JUMP:
			animation_player.play(&"jump")
			velocity = Tempo_Springen_Auf_Wand
			velocity.x *= get_wall_normal().x
			jump_request_timer.stop()
			statistik.heutige_energie -= SPRINGEN_ENERGIE
		State.ATTACK_1:
			animation_player.play(&"attack_1")
			is_combo_requested = false
			statistik.heutige_energie -= ANGRIFF_ENERGIE
		State.ATTACK_2:
			animation_player.play(&"attack_2")
			is_combo_requested = false
			statistik.heutige_energie -= ANGRIFF_ENERGIE
		State.ATTACK_3:
			animation_player.play(&"attack_3")
			is_combo_requested = false
			statistik.heutige_energie -= ANGRIFF_ENERGIE
		State.HURT:
			animation_player.play(&"hurt")
			
			#Die Gesundheit wird verringert.
			statistik.heutige_gesundheit -= pending_damage.menge
			
			#被击退
			var dir := pending_damage.quelle.global_position.direction_to(self.global_position)
			self.velocity = dir * KNOCKBACK_AMOUNT
				
			pending_damage = null
			unschlagbar_timer.start()
		State.TOT:
			print("[%s] Spieler: I will be back!" %[Engine.get_physics_frames()])
			unschlagbar_timer.stop()
			animation_player.play(&"tot")
			interacting_with.clear()
		State.SLIDING_START:
			animation_player.play(&"sliding_start")
			slide_request_timer.stop()
			statistik.heutige_energie -= SLIDING_ENERGIE
		State.SLIDING_LOOP:
			animation_player.play(&"sliding_loop")
		State.SLIDING_END:
			animation_player.play(&"sliding_end")
	
	if bis == State.WALL_JUMP:
		Engine.time_scale = 0.3
	if von == State.WALL_JUMP:
		Engine.time_scale = 1.0
	
	is_first_tick = true
	
func _on_hurt_box_hurt(hitbox: Hit_Box) -> void:
	if unschlagbar_timer.time_left > 0:
		return;
		
	print("[%s] Spieler: %s! You make me bleed!" %[Engine.get_physics_frames(), hitbox.owner.name])
	pending_damage = Schaden.new()
	pending_damage.menge = 1
	pending_damage.quelle = hitbox.owner
	if statistik.heutige_gesundheit == 0:
		queue_free()
