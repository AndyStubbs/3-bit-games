extends Node2D
class_name BlastBorder


var game: BlastGame
var clones: Array = []
var rect: Rect2 = Rect2( 10, 10, 500, 1000 )
var gravity: Vector2 = Vector2( 1, 0 )


@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var body: StaticBody2D = $StaticBody2D
@onready var body_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D


func init( new_game: BlastGame ) -> void:
	game = new_game
	init_texture()
	init_clones()


func init_clones() -> void:
	for i in range( game.worlds.size() ):
		var world = game.worlds[ i ]
		var clone = create_clone()
		clone.material = sprite.material
		clones.append( clone )
		world.add_child( clone )


func create_clone() -> Sprite2D:
	var clone: Sprite2D = Sprite2D.new()
	clone.z_index = z_index
	clone.centered = sprite.centered
	clone.scale = sprite.scale
	clone.modulate = sprite.modulate
	clone.texture = sprite.texture
	clone.position = position
	return clone


func init_texture() -> void:
	position = Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2
	)
	var image = Image.create(
		roundi( rect.size.x / 10 ),
		roundi( rect.size.y / 10 ),
		false,
		Image.FORMAT_RGB8
	)
	image.fill( Color.WHITE )
	var density: float = 100.0
	if rect.size.y > rect.size.x:
		density = rect.size.y / 10
	else:
		density = rect.size.x / 10
	var texture = ImageTexture.create_from_image( image )
	sprite.texture = texture
	sprite.scale = Vector2( 10, 10 )
	if game != null:
		sprite.material = game.create_border_material( Color( 0.35, 0.5, 0.85 ), density, gravity )
	area.gravity_direction = gravity
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = rect.size
	shape.shape = rect_shape
	body_shape.shape = rect_shape
	if gravity.x == 1:
		body.position.x = -150
	elif gravity.x == -1:
		body.position.x = 150
	elif gravity.y == 1:
		body.position.y = -150
	else:
		body.position.y = 150
