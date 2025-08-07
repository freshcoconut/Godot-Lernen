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
	camera_2d.limit_top = -28#used.position.y * tile_size.y
	camera_2d.limit_left = -194#used.position.x * tile_size.x
	camera_2d.limit_bottom = 442#used.end.y * tile_size.y
	camera_2d.limit_right = 878#used.end.x * tile_size.x
	#Kamera取消过渡动画
	camera_2d.reset_smoothing()
	
func spieler_aktualisieren(pos: Vector2, richtung: Spieler.Richtung) -> void:
	spieler.global_position = pos
	spieler.fall_from_y = pos.y
	spieler.richtung = richtung
	#Kamera取消过渡动画
	camera_2d.reset_smoothing()
