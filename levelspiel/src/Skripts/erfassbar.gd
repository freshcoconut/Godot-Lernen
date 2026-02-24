extends Area3D

enum ErfassbareType {
	DIAMOND,
	COIN,
	CHERRY,
}

@export var typ_erfassbar: ErfassbareType

@export var modell_diamond: PackedScene
@export var modell_coin: PackedScene
@export var modell_cherry: PackedScene
@export var modell_scale: Vector3 = Vector3(1.4, 1.4, 1.4)

@export var tempo_kreisen: float = 0.5
@export var tempo_schweben: float = 0.003
@export var groesse_schweben: float = 0.2

var urspruenglich_y: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	urspruenglich_y = position.y
	
	typ_erfassbar = randi_range(0, 2)
	
	var modell: PackedScene
	match typ_erfassbar:
		ErfassbareType.DIAMOND:
			modell = modell_diamond
		ErfassbareType.COIN:
			modell = modell_coin
		ErfassbareType.CHERRY:
			modell = modell_cherry
		_:
			printerr("Ungueltiger Typ!")
	
	var node_modell: Node3D = modell.instantiate()
	node_modell.scale = Vector3(1.4, 1.4, 1.4)
	add_child(node_modell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y += tempo_kreisen * delta
	position.y = urspruenglich_y + groesse_schweben * sin(Time.get_ticks_msec() * tempo_schweben)


func _on_body_entered(body: Node3D) -> void:
	SpielVerwalter.instanz.sammeln_ding(ErfassbareType.find_key(typ_erfassbar))
	queue_free()
