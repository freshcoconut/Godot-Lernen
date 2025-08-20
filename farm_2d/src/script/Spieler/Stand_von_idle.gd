class_name Stand_von_idle
extends Stand_des_Knotens

@export var spieler: CharacterBody2D
@export var animated_sprite_2d: AnimatedSprite2D

var richtung: Vector2

func _process(delta: float) -> void:#在现在的Godot版本中，需要把教程中的“_on_process()”改成“_process()”，把教程中的“_on_physics_process()”改成“_physics_process()”。否则游戏监测不到键盘的输入。
	pass
	
func _physics_process(delta: float) -> void:#在现在的Godot版本中，需要把教程中的“_on_process()”改成“_process()”，把教程中的“_on_physics_process()”改成“_physics_process()”。否则游戏监测不到键盘的输入。
	richtung = Ereignis_der_Eingabe_des_Spiels.eingabe_der_bewegung()
		
	match richtung:
		Vector2.UP:
			animated_sprite_2d.play(&"idle_hinter")
		
		Vector2.DOWN, Vector2.ZERO:
			animated_sprite_2d.play(&"idle_fort")
		Vector2.LEFT:
			animated_sprite_2d.play(&"idle_links")
		Vector2.RIGHT:
			animated_sprite_2d.play(&"idle_rechts")

func _im_naechsten_uebergang() -> void:
	pass

func _im_eingang() -> void:
	pass
	
func _im_ausgang() -> void:
	pass
