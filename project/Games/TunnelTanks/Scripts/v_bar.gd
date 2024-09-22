extends Panel


@export var value: float = 0:
	set( val ):
		value = clampf( val, 0, 100.0 )
		if is_loaded:
			update_size()


var width: float = 16
var max_y: float = 0
var base_y: float = 0
var is_loaded: bool = false


func _ready() -> void:
	width = size.x
	max_y = size.y
	base_y = position.y
	update_size()
	is_loaded = true


func update_size() -> void:
	var pct = value / 100.0
	size = Vector2( width, max_y * pct )
	position.y = base_y + ( max_y - size.y )
