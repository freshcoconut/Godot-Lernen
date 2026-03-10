class_name Stand_von_Gehen
extends Stand_des_Knotens

@export var spieler: Spieler_Haupt
@export var animated_sprite_2d: AnimatedSprite2D
@export var tempo:int = 60

func _on_process(delta: float) -> void:#教程中的“_on_process()”和“_on_physics_process()”是新的函数名称
	pass
	
func _on_physics_process(delta: float) -> void:#教程中的“_on_process()”和“_on_physics_process()”是新的函数名称
	var richtung: Vector2 = Ereignis_der_Eingabe_des_Spiels.eingabe_der_bewegung()
	match richtung:
		Vector2.UP:
			animated_sprite_2d.play(&"gehen_nach_oben")
		
		Vector2.DOWN:
			animated_sprite_2d.play(&"gehen_nach_unten")
		Vector2.LEFT:
			animated_sprite_2d.play(&"gehen_nach_links")
		Vector2.RIGHT:
			animated_sprite_2d.play(&"gehen_nach_rechts")
	
	if richtung != Vector2.ZERO:
		spieler.richtung_des_spielers = richtung
	
	spieler.velocity = richtung * tempo
	spieler.move_and_slide()

func _im_naechsten_uebergang() -> void:
	if ! Ereignis_der_Eingabe_des_Spiels.ist_eingabe_der_bewegung():
		uebergang_vom_stand_des_knotens.emit("Stand_von_Idle")

func _im_eingang() -> void:
	pass
	
func _im_ausgang() -> void:
	animated_sprite_2d.stop()
