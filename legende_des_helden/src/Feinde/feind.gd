class_name Feind
extends CharacterBody2D

enum Richtung {
	LINKS = -1,
	RECHTS = 1,
}
	
@export var max_tempo: float = 180
@export var beschleunigung: float = 2000

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var grafiken: Node2D = $Grafiken
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var maschine_des_standes: Maschine_des_Standes = $Maschine_des_Standes
@onready var statistik: Statistik = $Statistik

#Standardwert
@export var richtung := Richtung.LINKS:
	set(v):
		richtung = v
		if ! is_node_ready():
			await ready
		grafiken.scale.x = -richtung #当dir=-1，scale=-(-1)，负负得正

func move(tempo: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, tempo * richtung, beschleunigung * delta)  
	velocity.y += default_gravity * delta
	move_and_slide()
