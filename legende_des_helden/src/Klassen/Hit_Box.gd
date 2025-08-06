class_name Hit_Box
extends Area2D

signal hit(hurtbox)

func _init() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hurtbox: Hurt_Box) -> void:
	print("[%s] %s hits %s" % [Engine.get_physics_frames(), owner.name, hurtbox.owner.name])
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)
