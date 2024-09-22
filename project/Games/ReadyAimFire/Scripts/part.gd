extends Node2D


var is_grounded: bool = false
var last_pos: Vector2
var velocity: Vector2
var level: RAF_Level
var pattern: String


func _physics_process( delta: float ) -> void:
	last_pos = position
	position += velocity * delta
	velocity += level.gravity
	if velocity.y > 0:
		detect_ground_collision()


func init( new_level: RAF_Level, colors: Array, new_pattern: String ) -> void:
	pattern = new_pattern
	$Sprite2D.modulate = colors.pick_random()
	level = new_level
	
	if pattern == "dirt":
		velocity = Vector2(
			randf_range( -50, 50 ),
			randf_range( -150, -700 )
		)
	else:
		velocity = Vector2(
			randf_range( -50, 50 ),
			randf_range( -150, -300 )
		)
	position = Vector2(
		position.x + randf_range( -10, 10 ),
		position.y - 1
	)


func detect_ground_collision() -> void:
	var last: Vector2i = Vector2i(
		roundi( last_pos.x / level.scale ),
		roundi( last_pos.y / level.scale )
	)
	var pos: Vector2i = Vector2i(
		roundi( position.x / level.scale ),
		roundi( position.y / level.scale )
	)
	var points = Globals.get_points_on_line( last, pos )
	for point: Vector2i in points:
		if point.x >= 0 and point.x < level.width and point.y >= 0 and point.y < level.height:
			var color = level.img.get_pixel( point.x, point.y )
			if color != Color.BLACK:
				position = Vector2( point.x * level.scale, point.y * level.scale )
				is_grounded = true
				break
	if pos.y > level.height:
		is_grounded = true
	if is_grounded:
		position = last_pos
		level.on_particle_landed.emit( position, $Sprite2D.modulate, pattern )
		queue_free()
		return
