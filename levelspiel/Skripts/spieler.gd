extends CharacterBody3D
class_name Spieler

static var instanz_spieler: Spieler

@export var tempo = 5.0
@export var tempo_springen = 4.5

@export var camera: Camera3D
@export var modell: Node3D

var position_wiederbeleben: Vector3
var ziel_angle: float = PI

func _ready() -> void:
	if instanz_spieler == null:
		instanz_spieler = self
	else:
		queue_free()
		
	position_wiederbeleben = position

func _process(delta: float) -> void:
	var camera_angle = camera.global_rotation.y
	var input_dir := Input.get_vector("links", "rechts", "oben", "unten")
	var input_angle = atan2(input_dir.x, input_dir.y)
	if input_dir != Vector2.ZERO:
		ziel_angle = camera_angle + input_angle
		modell.global_rotation.y =  lerp_angle(modell.global_rotation.y, ziel_angle, delta * 12)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = tempo_springen

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("links", "rechts", "oben", "unten")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	if direction:
		velocity.x = direction.x * tempo
		velocity.z = direction.z * tempo
	else:
		velocity.x = move_toward(velocity.x, 0, tempo)
		velocity.z = move_toward(velocity.z, 0, tempo)

	move_and_slide()
