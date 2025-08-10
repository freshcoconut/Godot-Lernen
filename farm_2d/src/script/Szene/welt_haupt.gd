class_name  Welt_Haupt
extends Welt_Abstrakt

@onready var tile_map: TileMap = $TileMap
@onready var spieler_haupt: Spieler_Haupt = $Spieler_Haupt
@onready var camera_2d: Camera2D = $Spieler_Haupt/Camera2D

func _ready() -> void:
	var used := tile_map.get_used_rect().grow(-1)
	var tile_size := tile_map.tile_set.tile_size
	
	#position: the left top point of rectangle
	#end: the right bottom point of rectangle
	camera_2d.limit_top = used.position.y * tile_size.y
	camera_2d.limit_left = used.position.x * tile_size.x
	camera_2d.limit_bottom = used.end.y * tile_size.y
	camera_2d.limit_right = used.end.x * tile_size.x
	#Kamera取消过渡动画
	camera_2d.reset_smoothing()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
