class_name Stand_von_Idle
extends Stand_des_Knotens

@export var spieler: Spieler_Haupt
@export var animated_sprite_2d: AnimatedSprite2D

func _on_process(delta: float) -> void:#教程中的“_on_process()”和“_on_physics_process()”是新的函数名称
	pass
	
func _on_physics_process(delta: float) -> void:#教程中的“_on_process()”和“_on_physics_process()”是新的函数名称
	match spieler.richtung_des_spielers:
		Vector2.UP:
			animated_sprite_2d.play(&"idle_hinter")
		
		Vector2.DOWN, Vector2.ZERO:
			animated_sprite_2d.play(&"idle_fort")
		Vector2.LEFT:
			animated_sprite_2d.play(&"idle_links")
		Vector2.RIGHT:
			animated_sprite_2d.play(&"idle_rechts")

func _im_naechsten_uebergang() -> void:	
	Ereignis_der_Eingabe_des_Spiels.eingabe_der_bewegung()
	if Ereignis_der_Eingabe_des_Spiels.ist_eingabe_der_bewegung():
		uebergang_vom_stand_des_knotens.emit("Stand_von_Gehen")

func _im_eingang() -> void:
	pass
	
func _im_ausgang() -> void:
	animated_sprite_2d.stop()
