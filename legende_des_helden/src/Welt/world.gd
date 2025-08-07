extends Node2D

@onready var tile_map: TileMap = $TileMap
@onready var camera_2d: Camera2D = $Spieler/Camera2D
@onready var spieler: Spieler = $Spieler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:		
	var used := tile_map.get_used_rect().grow(-1)
	var tile_size := tile_map.tile_set.tile_size
	
	#position: the left top point of rectangle
	#end: the right bottom point of rectangle
	camera_2d.limit_top = -328#used.position.y * tile_size.y
	camera_2d.limit_left = -144#used.position.x * tile_size.x
	camera_2d.limit_bottom = 264#used.end.y * tile_size.y
	camera_2d.limit_right = 832#used.end.x * tile_size.x
	#Kamera取消过渡动画
	camera_2d.reset_smoothing()
	
func spieler_aktualisieren(pos: Vector2, richtung: Spieler.Richtung) -> void:
	spieler.global_position = pos
	spieler.fall_from_y = pos.y
	spieler.richtung = richtung
	#Kamera取消过渡动画
	camera_2d.reset_smoothing()
	
func to_dict() -> Dictionary:
	var betraege_lebendige_feinde := []
	
	for node in get_tree().get_nodes_in_group("feinde"):
		var path := get_path_to(node)
		betraege_lebendige_feinde.append(path)
		
	return {
		lebendige_feinde=betraege_lebendige_feinde
	}
	
func from_dict(dict: Dictionary) -> void:
	for node in get_tree().get_nodes_in_group("feinde"):
		var path := get_path_to(node)
		if !path in dict.lebendige_feinde:
			node.queue_free()
