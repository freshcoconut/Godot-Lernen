extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()
	set_process_input(false)

func _input(event: InputEvent) -> void:
	get_window().set_input_as_handled()
	
	if animation_player.is_playing():
		return
	
	if event is InputEventKey || event is InputEventMouseButton || event is InputEventJoypadButton:
		if event.is_pressed() && ! event.is_echo():
			Spiel.back_to_title()

func show_game_over() -> void:
	show()
	set_process_input(true)
	animation_player.play(&"enter")
	
