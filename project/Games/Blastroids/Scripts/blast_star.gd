extends Sprite2D


const blur_image = preload( "res://Assets/Images/star_blur.png" )
const blur_image2 = preload( "res://Assets/Images/star_blur2.png" )
const star_image = preload( "res://Assets/Images/star.png" )


@export var ship_body: BlastShipBody


var max_distance: float
var max_distance_squared: float
var area: Rect2
var warp_level: int = -1


func init() -> void:
	var size: float = randf_range( 0.5, 4.0 )
	scale = Vector2( size, size )
	modulate = Color( randf_range( 0, 0.5 ), randf_range( 0, 0.5 ), randf_range( 0.75, 1.0 ) )
	rotation = randf_range( 0, TAU )


func set_warp_mode( new_warp: int ) -> void:
	if warp_level != new_warp:
		if new_warp == 0:
			texture = star_image
			rotation = randf_range( 0, TAU )
		elif new_warp == 1:
			texture = blur_image
			rotation = ship_body.linear_velocity.angle()
		else:
			texture = blur_image2
			rotation = ship_body.linear_velocity.angle()
		warp_level = new_warp


func init_position() -> void:
	var expanse: float = 1000
	area = get_viewport_rect()
	area.size.x += expanse
	area.size.y += expanse
	area.position.x -= area.size.x / 2
	area.position.y -= area.size.y / 2
	max_distance = Vector2.ZERO.distance_to( get_viewport_rect().size ) / 2 * 1.25
	max_distance_squared = Vector2.ZERO.distance_squared_to( get_viewport_rect().size ) / 4 * 1.25
	position = Vector2(
		randf_range( area.position.x, area.position.x + area.size.x ),
		randf_range( area.position.y, area.position.y + area.size.y )
	)


func _ready() -> void:
	init_position()


func _physics_process( _delta: float ) -> void:
	
	# Wrap stars around viewport
	var pos = global_position - ship_body.global_position
	if pos.x < area.position.x:
		global_position.x += area.size.x
	elif pos.x > area.position.x + area.size.x:
		global_position.x -= area.size.x
	elif pos.y < area.position.y:
		global_position.y += area.size.y
	elif pos.y > area.position.y + area.size.y:
		global_position.y -= area.size.y
	
	# Set warp mode
	if ship_body.speed > 2000000:
		set_warp_mode( 2 )
	elif ship_body.speed > 1000000:
		set_warp_mode( 1 )
	else:
		set_warp_mode( 0 )
