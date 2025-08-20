class_name Ereignis_der_Eingabe_des_Spiels
extends Node

static var richtung_von_ereignis_der_eingabe: Vector2

static func eingabe_der_bewegung() -> Vector2:
	if Input.is_action_pressed("gehen_nach_oben"):
		richtung_von_ereignis_der_eingabe = Vector2.UP
		print("press: gehen_nach_oben")
	elif Input.is_action_pressed("gehen_nach_unten"):
		richtung_von_ereignis_der_eingabe = Vector2.DOWN
		print("press: gehen_nach_unten")
	elif Input.is_action_pressed("gehen_nach_links"):
		richtung_von_ereignis_der_eingabe = Vector2.LEFT
		print("press: gehen_nach_links")
	elif Input.is_action_pressed("gehen_nach_rechts"):
		richtung_von_ereignis_der_eingabe = Vector2.RIGHT
		print("press: gehen_nach_rechts")
	else:
		richtung_von_ereignis_der_eingabe = Vector2.ZERO
	
	return richtung_von_ereignis_der_eingabe

static func ist_eingabe_der_bewegung() -> bool:
	if richtung_von_ereignis_der_eingabe == Vector2.ZERO:
		return false
	else:
		return true
