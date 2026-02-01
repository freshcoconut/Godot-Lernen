extends CharacterBody3D


@export var tempo = 5.0
@export var tempo_springen = 4.5

@export var camera: Camera3D

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
