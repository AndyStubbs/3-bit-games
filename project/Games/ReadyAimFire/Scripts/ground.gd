extends Sprite2D
class_name RAF_Ground


var level: RAF_Level
var needs_update: bool = false
var images: Dictionary = {}


@onready var poly: CollisionPolygon2D = $Body/Poly


func init( new_level: RAF_Level ) -> void:
	for r_color in Raf.ROCK_COLORS:
		Globals.filter_colors.append( r_color )
	level = new_level
	level.on_bridge_landed.connect( on_bridge_landed )
	level.on_particle_landed.connect( on_particle_landed )
	level.on_shovel_landed.connect( on_shovel_landed )
	level.on_laser_fired.connect( on_laser_fired )
	var width = level.width
	var height = level.height
	level.img = Image.create( width, height, false, Image.FORMAT_RGB8 )
	level.rock_img = Image.create( width, height, false, Image.FORMAT_RGB8 )
	level.rock_mask = Image.create( width, height, false, Image.FORMAT_RGBA8 )
	level.rect = Rect2i( 0, 0, width, height )
	texture = ImageTexture.create_from_image( level.img )
	for x in range( width ):
		for y in range( height ):
			var color: Color = Color.BLACK
			var color_r: Color = Color.BLACK
			var color_m: Color = Color( 0, 0, 0, 0 )
			if y == level.rock_heights[ x ]:
				color = Raf.ROCK_COLORS[ 0 ]
				color_r = color
				color_m = Color.WHITE
			elif y > level.rock_heights[ x ]:
				color = Raf.ROCK_COLORS.pick_random()
				color_r = color
				color_m = Color.WHITE
			elif y == level.heights[ x ]:
				color = Raf.DIRT_COLORS[ Raf.DIRT_COLORS.size() - 1 ]
			elif y > level.heights[ x ]:
				color = Raf.DIRT_COLORS.pick_random()
			level.img.set_pixel( x, y, color )
			level.rock_img.set_pixel( x, y, color_r )
			level.rock_mask.set_pixel( x, y, color_m )
	texture.update( level.img )
	update_body()


func _physics_process( _delta: float ) -> void:
	if needs_update:
		texture.update( level.img )
		needs_update = false
	var skip: bool = false
	if level.explosions.size() > 0:
		var is_shifted: bool = false
		var temp: Array = []
		temp.append_array( level.explosions )
		for explosion in level.explosions:
			if explosion.radius > 0:
				var id = str( explosion.radius )
				if Raf.explosions.has( id ):
					var exp_img: Dictionary = Raf.explosions[ id ]
					var dst: Vector2i = Vector2i(
						explosion.pos.x - explosion.radius,
						explosion.pos.y - explosion.radius
					)
					level.img.blit_rect_mask( exp_img.image, exp_img.mask, exp_img.rect, dst )
					level.img.blit_rect_mask(
						level.rock_img, level.rock_mask, level.rect, Vector2i.ZERO
					)
				else:
					Globals.draw_filled_circle(
						level.img, Color.BLACK, explosion.pos.x, explosion.pos.y, explosion.radius
					)
			if explosion.has( "skip" ):
				skip = explosion.skip
			is_shifted = shift_pixels_down( explosion.pos.x, explosion.radius + 2, skip )
		texture.update( level.img )
		level.explosions = []
		#update_body()
		
		while is_shifted:
			if not is_inside_tree():
				return
			await get_tree().physics_frame
			for explosion in temp:
				is_shifted = shift_pixels_down( explosion.pos.x, explosion.radius + 2, skip )
			texture.update( level.img )
		update_body()


func shift_pixels_down( cx: int, radius: int, skip: bool = false ) -> bool:
	var is_shifted: bool = false
	for x in range( max( cx - radius, 0 ), min( cx + radius, level.width - 1 ) ):
		var last_pixel_y: int = -1
		for y in range( 0, level.height ):
			var color = level.img.get_pixel( x, y )
			if color == Color.BLACK:
				if last_pixel_y > -1:
					level.img.set_pixel( x, last_pixel_y, Color.BLACK )
					level.img.set_pixel( x, y, Raf.DIRT_COLORS.pick_random() )
					is_shifted = true
				last_pixel_y = -1
			else:
				last_pixel_y = y
	update_heights( cx, radius, skip )
	return is_shifted


func update_heights( cx: int, radius: int, skip: bool = false ) -> void:
	for x in range( max( cx - radius, 0 ), min( cx + radius, level.width - 1 ) ):
		for y in range( level.height ):
			var color: Color = level.img.get_pixel( x, y )
			if color != Color.BLACK:
				level.heights[ x ] = y
				if not Globals.is_filtered_color( color ):
					level.img.set_pixel( x, y, Raf.DIRT_COLORS[ Raf.DIRT_COLORS.size() - 1 ] )
				break
	if not skip:
		level.on_heights_updated.emit()


func update_body() -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var x: float
	var y: float
	for x2 in range( 0, level.heights.size(), 3 ):
		x = x2 * level.scale
		y = level.heights[ x2 ] * level.scale
		points.append( Vector2( x, y ) )
	
	# Extend points out to the right
	#points.append( 
	#	Vector2( level.width * level.scale + 100, y )
	#)
	# Extend down to the bottem right
	points.append( 
		Vector2( level.width * level.scale, level.height * level.scale )
	)
	# Extend Back to the left
	points.append(
		Vector2( 0, level.height * level.scale )
	)
	poly.polygon = points


func on_particle_landed( pos: Vector2, color: Color, pattern: String ) -> void:
	var x: int = roundi( pos.x / level.scale )
	if x >= 0 and x < level.width:
		var y: int
		if pattern == "slime":
			y = level.heights[ x ] - 1
			level.img.set_pixel( x, y, color )
			level.heights[ x ] = y
			needs_update = true
		else:
			y = roundi( pos.y / level.scale )
			level.img.set_pixel( x, y, color )
			level.heights[ x ] = y
			level.explosions.append( {
				"pos": Vector2i( x, y ),
				"radius": 0,
				"skip": true
			} )


func on_bridge_landed( pos: Vector2, vel: Vector2 ) -> void:
	var bridge_width: int = 60
	var start = Vector2i( roundi( pos.x / level.scale ), roundi( pos.y / level.scale ) )
	var end = Vector2i.ZERO
	if vel.x > 0:
		end.x = start.x - bridge_width
	else:
		end.x = start.x + bridge_width
	if start.x < 0 or start.x > level.width - 1:
		return
	if end.x < 0:
		end.x = 0
	elif end.x > level.width - 1:
		end.x = level.width - 1
	if start.x == end.x:
		return
	#start.y = level.heights[ start.x ]
	end.y = level.heights[ end.x ]
	var points: Array = Globals.get_points_on_line( start, end )
	for pt in points:
		if pt.y > level.heights[ pt.x ]:
			continue
		level.heights[ pt.x ] = pt.y
		level.img.set_pixel( pt.x, pt.y, Raf.DIRT_COLORS[ Raf.DIRT_COLORS.size() - 1 ] )
		for y in range( pt.y + 1, level.height - 1 ):
			var color: Color = level.img.get_pixel( pt.x, y )
			if color == Color.BLACK:
				level.img.set_pixel( pt.x, y, Raf.DIRT_COLORS.pick_random() )
			else:
				break
		needs_update = true
		if not is_inside_tree():
			return
		await get_tree().physics_frame
	update_body()


func on_shovel_landed( pos: Vector2, vel: Vector2 ) -> void:
	pos = pos / level.scale
	vel = vel.normalized()
	for radius in range( 8, 1, -1 ):
		level.explosions.append( {
			"pos": Vector2i( roundi( pos.x ), roundi( pos.y ) ),
			"radius": radius
		} )
		pos += vel * radius
		if not is_inside_tree():
			return
		await get_tree().physics_frame


func on_laser_fired( start: Vector2i, end: Vector2i ) -> void:
	var points = Globals.get_points_on_line( start, end )
	var points2: Array = []
	var is_shifted: bool = false
	for pt in points:
		if pt.x < 0 or pt.x > level.width - 1 or pt.y < 1 or pt.y > level.height - 1:
			break
		var color1 = level.img.get_pixel( pt.x, pt.y )
		var color2 = level.img.get_pixel( pt.x, pt.y - 1 )
		if not Globals.is_filtered_color( color1 ) and color1 != Color.BLACK:
			is_shifted = true
			level.img.set_pixel( pt.x, pt.y, Color.BLACK )
			level.heights[ pt.x ] += 1
			points2.append( pt )
		if not Globals.is_filtered_color( color2 ) and color2 != Color.BLACK:
			is_shifted = true
			level.img.set_pixel( pt.x, pt.y - 1, Color.BLACK )
			level.heights[ pt.x ] += 1
			points2.append( pt )
	texture.update( level.img )
	
	await  get_tree().create_timer( 1.5 ).timeout
	if is_shifted:
		$GroundSound.play()
	#await get_tree().create_timer( 0.25 ).timeout
	var ground_color = Raf.DIRT_COLORS[ Raf.DIRT_COLORS.size() - 1 ]
	for pt in points2:
		level.img.set_pixel( pt.x, level.heights[ pt.x ] - 1, Color.BLACK )
		level.img.set_pixel( pt.x, level.heights[ pt.x ] - 2, Color.BLACK )
		level.img.set_pixel( pt.x, level.heights[ pt.x ], ground_color )
		for y in range( level.heights[ pt.x ] + 1, pt.y + 1):
			level.img.set_pixel( pt.x, y, Raf.DIRT_COLORS.pick_random() )
	texture.update( level.img )
	
	if is_shifted:
		level.on_heights_updated.emit()
		update_body()
