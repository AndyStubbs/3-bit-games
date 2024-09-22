extends Sprite2D


const SIZE: float = 50.0
const DOT_POS: Vector2 = Vector2( 128, 102 )
const base_texture: Texture = preload( "res://Games/TunnelTanks/Images/base.png" )


var tank: TUN_Tank
var max_width: float = 0
var max_height: float = 0
var offset_x: float = 0
var offset_y: float = 0
var base_data: Array = []


@onready var dot = $Dot


func _ready() -> void:
	tank = get_parent().get_parent().get_node(
		"SubViewportContainer/SubViewport/World/Tank"
	)
	Tun.on_sprite_ready.emit( self, Tun.SPRITE_TYPES.MINIMAP )
	max_width = texture.get_width() - ( SIZE * 2.0 ) / scale.x
	max_height = texture.get_height() - ( SIZE * 2.0 ) / scale.y
	offset_x = ( SIZE * 1.25 / scale.x )
	offset_y = ( SIZE / scale.y )
	
	await get_tree().process_frame
	dot.modulate = tank.color2
	dot.modulate.r = clampf( dot.modulate.r + 0.25, 0, 1 )
	dot.modulate.g = clampf( dot.modulate.g + 0.25, 0, 1 )
	dot.modulate.b = clampf( dot.modulate.b + 0.25, 0, 1 )
	
	for t2 in Tun.game_data.tanks:
		var base = t2.base
		var sprite = Sprite2D.new()
		sprite.scale = Vector2( 2, 2 )
		sprite.texture = base_texture
		sprite.modulate = t2.color2
		sprite.show_behind_parent = true
		add_child( sprite )
		base_data.append( [ base, sprite ] )


func _process( _delta: float ) -> void:
	
	# Set dot position
	var pos: Vector2 = Vector2( tank.position.x - offset_x, tank.position.y - offset_y )
	region_rect.position = Vector2(
		clampf( pos.x, 0, max_width ),
		clampf( pos.y, 0, max_height )
	)
	var diff = pos - region_rect.position
	dot.position = DOT_POS + diff
	
	# Set base positions
	for data in base_data:
		var base = data[ 0 ]
		var sprite = data[ 1 ]
		var base_pos: Vector2 = Vector2(
			base.position.x - offset_x,
			base.position.y - offset_y
		)
		var base_diff = base_pos - region_rect.position
		sprite.position = DOT_POS + base_diff + Vector2( 15, 15 )
