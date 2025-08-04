extends CharacterBody2D

const Tempo := 200.0 #200 pixel pro Sekunde
const Tempo_Springen := -300.0
var gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	var Richtung := Input.get_axis("sich_nach_links_bewegen", "sich_nach_rechts_bewegen")
	velocity.x = Richtung * Tempo
	velocity.y += gravity * delta
	move_and_slide()
	
	if is_on_floor() && Input.is_action_just_pressed("springen"):
		velocity.y = Tempo_Springen
		
	if is_on_floor():
		if is_zero_approx(Richtung):
			animation_player.play("idle")
		else:
			animation_player.play("running")
	else:
		animation_player.play("jump")
		
	if ! is_zero_approx(Richtung):
		sprite_2d.flip_h = Richtung < 0
