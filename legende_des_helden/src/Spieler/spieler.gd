extends CharacterBody2D

const Tempo := 120.0 #200 pixel pro Sekunde
const Tempo_Springen := -300.0
const Grund_Beschleunigung := Tempo / 0.2 # 0.2s for acceleration
const Himmel_Beschleunigung := Tempo / 0.02 # 0.02s for acceleration
var gravity := ProjectSettings.get("physics/2d/default_gravity") as float

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

func _physics_process(delta: float) -> void:
	var Richtung := Input.get_axis("sich_nach_links_bewegen", "sich_nach_rechts_bewegen")
	var Beschleunigung = Grund_Beschleunigung if is_on_floor() else Himmel_Beschleunigung
	velocity.x = move_toward(velocity.x, Richtung * Tempo, Beschleunigung * delta)  
	velocity.y += gravity * delta
	
	var can_jump := is_on_floor() || coyote_timer.time_left > 0
	var should_jump := can_jump && jump_request_timer.time_left > 0
	if should_jump:
		velocity.y = Tempo_Springen
		coyote_timer.stop()
		jump_request_timer.stop()
	
	var was_on_floor := is_on_floor()
	move_and_slide()
	if is_on_floor() != was_on_floor:
		if was_on_floor && !should_jump:
			coyote_timer.start()
		else:
			coyote_timer.stop()
		
	if is_on_floor():
		if is_zero_approx(Richtung) && is_zero_approx(velocity.x):
			animation_player.play("idle")
		else:
			animation_player.play("running")
	else:
		animation_player.play("jump")
		
	if ! is_zero_approx(Richtung):
		sprite_2d.flip_h = Richtung < 0
