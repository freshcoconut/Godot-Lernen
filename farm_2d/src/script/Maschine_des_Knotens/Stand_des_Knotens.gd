class_name Stand_des_Knotens
extends Node

@warning_ignore("unused_signal")
signal uebergang_vom_stand_des_knotens

func _process(delta: float) -> void:#在现在的Godot版本中，需要把教程中的“_on_process()”改成“_process()”，把教程中的“_on_physics_process()”改成“_physics_process()”。否则游戏监测不到键盘的输入。
	pass
	
func _physics_process(delta: float) -> void:#在现在的Godot版本中，需要把教程中的“_on_process()”改成“_process()”，把教程中的“_on_physics_process()”改成“_physics_process()”。否则游戏监测不到键盘的输入。
	pass

func _im_naechsten_uebergang() -> void:
	pass

func _im_eingang() -> void:
	pass
	
func _im_ausgang() -> void:
	pass
