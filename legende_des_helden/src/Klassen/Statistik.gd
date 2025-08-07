class_name Statistik
extends Node

signal gesundheit_geaendert
signal energie_geaendert

@export var max_Gesundheit: int = 8
@export var max_Energie: float = 10 # 能量恢复时可能会恢复0.1、0.2个单位的能量
@export var energie_regen: float = 0.6 # energie_regen for every second

@onready var heutige_gesundheit: int = max_Gesundheit:
	set(v):
		v = clampi(v, 0, max_Gesundheit)
		if v == heutige_gesundheit:
			return
		heutige_gesundheit = v
		gesundheit_geaendert.emit()
		
@onready var heutige_energie: float = max_Energie:
	set(v):
		v = clampf(v, 0, max_Energie)
		if v == heutige_energie:
			return
		heutige_energie = v
		energie_geaendert.emit()
		
func _process(delta: float) -> void:
	heutige_energie += energie_regen * delta # energie_regen for every second
