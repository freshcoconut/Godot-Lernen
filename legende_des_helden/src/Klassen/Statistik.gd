class_name Statistik
extends Node

@export var max_Gesundheit: int = 3

@onready var heutige_gesundheit: int = max_Gesundheit:
	set(v):
		v = clampi(v, 0, max_Gesundheit)
		if v == heutige_gesundheit:
			return
		heutige_gesundheit = v
