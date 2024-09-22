extends Node


const LANGUAGES: Array = [ "en", "es" ]
const SETTINGS_FILE: String = "threebit.json"
const PLAYER_COLORS: Array = [
	[ Color( 0.0, 0.0, 0.1 ), Color( 0.2, 0.2, 0.9 ), Color( 0.3, 0.6, 0.8 ) ],	# BLUE
	[ Color( 0.1, 0.1, 0.0 ), Color( "#f2ff38" ), Color( "#acb928" ) ],     # YELLOW
	[ Color( 0.1, 0.0, 0.1 ), Color( 0.8, 0.5, 0.8 ), Color( 0.5, 0.3, 0.5 ) ],	# PINK
	[ Color( 0.0, 0.1, 0.0 ), Color( 0.2, 0.9, 0.2 ), Color( 0.1, 0.5, 0.2 ) ],	# GREEN
	[ Color( 0.1, 0.1, 0.0 ), Color( 0.9, 0.2, 0.2 ), Color( 0.5, 0.1, 0.1 ) ],	# RED
	[ Color( 0.0, 0.1, 0.1 ), Color( 0.2, 0.8, 0.8 ), Color( 0.1, 0.5, 0.5 ) ],	# CYAN
	[ Color( 0.0, 0.1, 0.1 ), Color( "#ffa938" ),     Color( "#bf7908" )  ],	# ORANGE
	[ Color( 0.3, 0.3, 0.3 ), Color( 0.1, 0.1, 0.1 ), Color( 0.6, 0.6, 0.6 ) ],	# BLACK
	[ Color( 0.0, 0.1, 0.1 ), Color( "#8728df" ),     Color( "#b848ff" )  ],	# PURPLE
	[ Color( 0.0, 0.1, 0.1 ), Color( "#bcbcbc" ),     Color( "#585858" )  ],	# WHITE
]
const BLAST_COLORS: Array = [
	Color( 0.2, 0.2, 0.9 ),		# BLUE
	Color( 0.5, 0.5, 0.0 ),		# YELLOW
	Color( 0.6, 0.2, 0.6 ),		# PINK
	Color( 0.0, 0.6, 0.0 ),		# GREEN
	Color( 0.9, 0.2, 0.2 ),		# RED
	Color( 0.1, 0.7, 0.7 ),		# CYAN,
	Color( "#bf7908" ),			# ORANGE
	Color( 0.1, 0.1, 0.1 ),		# BLACK
	Color( "#8728df" ),			# PURPLE
	Color( "#686868" ),			# WHITE
]
const RAF_IMAGES: Array = [
	preload( "res://Games/ReadyAimFire/Images/ui_tank_horizontal.png" )
]
const TUN_IMAGES: Array = [
	preload( "res://Games/TunnelTanks/Images/ui_tun_tank_v.png" )
]
const BLAST_IMAGES: Array = [
	[
		preload( "res://Games/Blastroids/Images/spaceship3_0.png" ), 
		preload( "res://Games/Blastroids/Images/spaceship3_markers3.png" )
	],
	[
		preload( "res://Games/Blastroids/Images/spaceship4_0.png" ),
		preload( "res://Games/Blastroids/Images/spaceship4_markers2.png" )
	]
]
const CONTROL_NAMES: Dictionary = {
	"P0": "TR_WASD",
	"P1": "TR_ARROWS",
	"ANY": "TR_ALL_CONTROLS",
	"CPU": "TR_CPU",
	"J0": "TR_GAMEPAD_0",
	"J1": "TR_GAMEPAD_1",
	"J2": "TR_GAMEPAD_2",
	"J3": "TR_GAMEPAD_3"
}
const PLAYERS_DEFAULT: Array = [
	{
		"id": 0,
		"enabled": true,
		"name": "TR_PLAYER_1",
		"controls": "ANY",
		"colors": 0,
		"image_id": 0,
		"name_changed": false
	}, {
		"id": 1,
		"enabled": true,
		"name": "TR_PLAYER_2",
		"controls": "ANY",
		"colors": 1,
		"image_id": 0,
		"name_changed": false
	}, {
		"id": 2,
		"enabled": false,
		"name": "TR_PLAYER_3",
		"controls": "ANY",
		"colors": 2,
		"image_id": 0,
		"name_changed": false
	}, {
		"id": 3,
		"enabled": false,
		"name": "TR_PLAYER_4",
		"controls": "ANY",
		"colors": 3,
		"image_id": 0,
		"name_changed": false
	}
]


signal on_player_updated
signal on_fullscreen_mode_toggled( is_fullscreen: bool )
signal on_cursor_mode_toggled

@warning_ignore( "unused_signal" )
signal on_language_changed


var is_debug: bool = false
var filter_colors: Array = []
var players = []
var is_loading_settings: bool = false
var is_cursor_mode: bool = false:
	set( value ):
		is_cursor_mode = value
		on_cursor_mode_toggled.emit()
var is_menu_page: bool = false
var main_menu_scene: PackedScene = load( "res://Shared/main_menu.tscn" )
var is_mute: bool = false
var language_id: int = 0
var is_fullscreen: bool = false


func _ready() -> void:
	is_debug = OS.get_cmdline_args().find( "debug" ) != -1
	for pl in PLAYERS_DEFAULT:
		players.append( {
			"id": pl.id,
			"enabled": pl.enabled,
			"name": pl.name,
			"controls": pl.controls,
			"colors": pl.colors,
			"image_id": pl.image_id,
			"name_changed": pl.name_changed
		} )
	is_loading_settings = true
	load_settings()
	is_loading_settings = false
	if is_fullscreen:
		set_window_mode( true )
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index( "Master" ), -6.0 )
	TranslationServer.set_locale( Globals.LANGUAGES[ language_id ] )


func _unhandled_input( _event: InputEvent ) -> void:
	if Input.is_action_just_pressed( "Fullscreen" ):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			set_window_mode( false )
			save_settings()
			on_fullscreen_mode_toggled.emit( false )
		else:
			set_window_mode( true )
			save_settings()
			on_fullscreen_mode_toggled.emit( true )


func set_window_mode( new_is_fullscreen: bool ) -> void:
	is_fullscreen = new_is_fullscreen
	if is_fullscreen:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode( DisplayServer.WINDOW_MODE_FULLSCREEN )
	else:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode( DisplayServer.WINDOW_MODE_WINDOWED )


func get_default_player_settings( id: int ) -> Dictionary:
	var pl = PLAYERS_DEFAULT[ id ]
	return {
		"id": pl.id,
		"enabled": pl.enabled,
		"name": pl.name,
		"controls": pl.controls,
		"colors": pl.colors,
		"image_id": 0,
		"name_changed": pl.name_changed
	}


func update_player_settings( player_settings: Dictionary ) -> void:
	players[ player_settings.id ] = player_settings
	save_settings()
	on_player_updated.emit()


func get_image_data( img: Image, start: Vector2i, img_size: Vector2i ) -> Array:
	var data = []
	for y in img_size.y:
		var data_row = []
		for x in img_size.x:
			var color = img.get_pixel( x + start.x, y + start.y )
			if color.a == 0:
				data_row.append( 0 )
			else:
				data_row.append( 1 )
		data.append( data_row )
	return data


func calc_color_distance( color1: Color, color2: Color ) -> float:
	var diff_r = color1.r - color2.r
	var diff_g = color1.g - color2.g
	var diff_b = color1.b - color2.b
	var diff = ( diff_r * diff_r ) + ( diff_g * diff_g ) + ( diff_b * diff_b )
	
	return diff


func are_colors_simular( color1: Color, color2: Color, tolerance: float = 0.01 ) -> bool:
	var diff = calc_color_distance( color1, color2 )
	return diff < tolerance


func is_filtered_color( color: Color ) -> bool:
	for f_color in filter_colors:
		if are_colors_simular( color, f_color ):
			return true
	return false


func blend_colors( color_a: Color, color_b: Color, ratio: float ) -> Color:
	# Clamp the ratio between 0 and 1 to avoid out-of-bound values
	ratio = clamp(ratio, 0.0, 1.0)
	
	# Perform linear interpolation (lerp) on each color channel (r, g, b, and a)
	var blended_color = Color(
		lerp( color_a.r, color_b.r, ratio ),
		lerp( color_a.g, color_b.g, ratio ),
		lerp( color_a.b, color_b.b, ratio ),
		lerp( color_a.a, color_b.a, ratio )  # Blend alpha as well, if needed
	)

	return blended_color


func draw_filled_circle( img: Image, color: Color, x: int, y: int, radius: int ) -> void:
	
	# Define the bounding box of the circle
	var min_x = max( 0, x - radius )
	var max_x = min( img.get_width() - 1, x + radius )
	var min_y = max( 0, y - radius )
	var max_y = min( img.get_height() - 1, y + radius )
	
	# Calculate the square of the radius to avoid computing the square root in the loop
	var radius_squared = radius * radius
	
	# Draw the filled circle within the bounding box
	for i in range( min_x, max_x + 1 ):
		for j in range( min_y, max_y + 1 ):
			var dx = i - x
			var dy = j - y
			if ( dx * dx + dy * dy ) <= radius_squared:
				var px_color: Color = img.get_pixel( i, j )
				if not is_filtered_color( px_color ):
					img.set_pixel( i, j, color )


func draw_line( img: Image, color: Color, start: Vector2, end: Vector2 ) -> void:
	var width = img.get_width() - 1
	var height = img.get_height() - 1
	var points: Array = get_points_on_line( start, end )
	for point in points:
		point.x = clampi( point.x, 0, width )
		point.y = clampi( point.y, 0, height )
		img.set_pixelv( point, color )


func create_rock( rect: Rect2, p_range: Vector2i, vary: float = 0.125, vary2: float = 0.25 ) -> Array:
	var points = []
	var vary_x = rect.size.x * vary
	var r_min_x = rect.size.x * vary2
	var r_max_x = rect.size.x / 2
	var vary_y = rect.size.y * vary
	var r_min_y = rect.size.y * vary2
	var r_max_y = rect.size.y / 2
	var cx = rect.size.x / 2
	var cy = rect.size.y / 2
	var num_points = randi_range( p_range.x, p_range.y )
	for i in range( num_points ):
		var angle = ( i / float( num_points ) ) * 2 * PI
		var radius_x = randf_range( r_min_x, r_max_x )
		var radius_y = randf_range( r_min_y, r_max_y )
		var x = cx + radius_x * cos( angle ) + randf_range( -vary_x, vary_x )
		var y = cy + radius_y * sin( angle ) + randf_range( -vary_y, vary_y )
		x = floori( clampf( x, 0, rect.size.x - 1 ) )
		y = floori( clampf( y, 0, rect.size.y - 1 ) )
		points.append( Vector2i( x, y ) )
	return points


func draw_rock( img: Image, points: Array, rect: Rect2, colors: Array, b_color: Color ) -> void:
	var cx = rect.size.x / 2
	var cy = rect.size.y / 2
	var num_points = points.size()
	
	# Draw the rock on a temporary image
	var i_temp = Image.create(
		floori( rect.size.x ), floori( rect.size.y ), false, Image.FORMAT_RGB8
	)
	i_temp.fill( Color.BLACK )
	for i in range( num_points ):
		var next_i = ( i + 1 ) % num_points
		draw_line( i_temp, b_color, points[ i ], points[ next_i ] )
	flood_fill( i_temp, Vector2( cx, cy ), colors )
	
	# Copy the colored pixels to the source image
	for y in range( 0, rect.size.y ):
		for x in range( 0, rect.size.x ):
			var c = i_temp.get_pixel( x, y )
			if c != Color.BLACK:
				img.set_pixel( floori( rect.position.x ) + x, floori( rect.position.y ) + y, c )


func flood_fill( img: Image, seed_point: Vector2, fill_colors: Array ):
	var base_color = img.get_pixelv( seed_point )
	for c in fill_colors:
		if are_colors_simular( base_color, c ):
			return
	var stack = [ seed_point ]
	while stack.size() > 0:
		var point = stack.pop_back()

		# Make sure the point is within bounds
		if point.x < 0 or point.y < 0 or point.x >= img.get_width() or point.y >= img.get_height():
			continue

		# Get the color of the current point
		var current_color = img.get_pixelv( point )
		
		# Only fill colors that are the same as base color
		if are_colors_simular( current_color, base_color ):
			img.set_pixelv( point, fill_colors.pick_random() )
			
			# Add neighboring points to the stack for checking
			stack.append( point + Vector2( 1, 0 ) )  # Right
			stack.append( point + Vector2( -1, 0 ) ) # Left
			stack.append( point + Vector2( 0, 1 ) )  # Down
			stack.append( point + Vector2( 0, -1 ) ) # Up


func draw_cracks( img: Image, colors: Array ) -> void:
	var w = img.get_width()
	var h = img.get_height()
	var r = sqrt( w * w + h * h ) / 2
	var l = randf_range( r / 8, r )
	var branches = [
		Vector2( randf_range( 0, w ), randf_range( 0, h ) )
	]
	var ma = randf_range( 0, TAU )
	var buff: int = 5
	var offsets: Array = [
		[  0,  0, colors[ 0 ] ],
		[ -1,  0, colors[ 1 ] ],
		[  1,  0, colors[ 1 ] ],
		[  0, -1, colors[ 1 ] ],
		[  0,  1, colors[ 1 ] ],
	]
	while l > 0:
		var branch = branches.pop_back()
		var start = Vector2(
			clampf( branch.x, buff, img.get_width() - buff ),
			clampf( branch.y, buff, img.get_height() - buff ) 
		)
		var a = ma + randf_range( -PI / 2, PI / 2 )
		var d = randf_range( 3, 6 )
		l -= d
		var end = Vector2(
			clampf(  branch.x + cos( a ) * d, buff, img.get_width() - buff ),
			clampf( branch.y + sin( a ) * d, buff, img.get_height() - buff ) 
		)
		var points: Array = Globals.get_points_on_line( start, end )
		for point in points:
			for off in offsets:
				var c = img.get_pixel( point.x + off[ 0 ], point.y + off[ 1 ] )
				if c != Color( 0, 0, 0, 0 ):
					var c2 = Globals.blend_colors( c, off[ 2 ], 0.15 )
					img.set_pixel( point.x + off[ 0 ], point.y + off[ 1 ], c2 )
		branches.append( end )
		if randf_range( 0, 1 ) > 0.5:
			branches.append( end )


func is_point_in_polygon2( point: Vector2, polygon: Array ) -> bool:
	var inside = false
	for i in range( polygon.size() ):
		var j = ( i + 1 ) % polygon.size()
		var xi = polygon[ i ].x
		var yi = polygon[ i ].y
		var xj = polygon[ j ].x
		var yj = polygon[ j].y
		var is_between_y_bounds = ( yi > point.y ) != ( yj > point.y )
		var slope = ( xj - xi ) / ( yj - yi )
		var intercept_x_at_point_y = slope * ( point.y - yi ) + xi
		var is_point_left_of_edge = point.x < intercept_x_at_point_y
		var intersect = is_between_y_bounds and is_point_left_of_edge
		if intersect:
			inside = not inside
	return inside


func is_point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var inside = false
	var num_points = polygon.size()
	
	for i in range(num_points):
		# Get current and next vertices of the polygon
		var current_vertex = polygon[i]
		var next_vertex = polygon[(i + 1) % num_points]

		# Get x and y values for current and next vertices
		var xi = current_vertex.x
		var yi = current_vertex.y
		var xj = next_vertex.x
		var yj = next_vertex.y

		# Check if point is between the y bounds of the edge
		var is_between_y_bounds = (yi > point.y) != (yj > point.y)
		
		# Only calculate the slope and intercept if the point is within the y bounds
		if is_between_y_bounds:
			var slope = (xj - xi) / (yj - yi)
			var intercept_x_at_point_y = slope * (point.y - yi) + xi
			
			# Check if the point is to the left of the edge
			if point.x < intercept_x_at_point_y:
				inside = not inside
	return inside


func swap_colors( anim: AnimatedSprite2D, base_c: Array, swap_c: Array ) -> void:
	var new_sprite_frames = SpriteFrames.new()
	for animation in anim.sprite_frames.get_animation_names():
		new_sprite_frames.add_animation( animation )
		for f in range( anim.sprite_frames.get_frame_count( animation ) ):
			var texture: Texture2D = anim.sprite_frames.get_frame_texture( animation, f )
			var image = texture.get_image()
			swap_colors_img( image, base_c, swap_c )
			var t2 = ImageTexture.create_from_image( image )
			new_sprite_frames.add_frame( animation, t2 )
	anim.sprite_frames = new_sprite_frames


func swap_colors_img( image: Image, base_c: Array, swap_c: Array ) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color: Color = image.get_pixel( x, y )
			if color.a != 0:
				for i in range( swap_c.size() ):
					var sc = swap_c[ i ]
					if Globals.are_colors_simular( sc, color ):
						image.set_pixel( x, y, base_c[ i ] )


func get_points_on_line( start: Vector2i, end: Vector2i ) -> Array:
	var points: Array = []
	var x1 = start.x
	var y1 = start.y
	var x2 = end.x
	var y2 = end.y

	var dx = abs( x2 - x1 )
	var dy = abs( y2 - y1 )
	var sx = -1
	var sy = -1
	if x1 < x2: sx = 1
	if y1 < y2: sy = 1
	var err = dx - dy

	while true:
		points.append( Vector2i( x1, y1 ) )

		if x1 == x2 and y1 == y2:
			break
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x1 += sx
		if e2 < dx:
			err += dx
			y1 += sy
			
	return points


func debug_circle( point: Vector2, color: Color, radius: float, width: float, parent: Node2D, fade: float = 0 ) -> void:
	if not is_debug: return
	var line = Line2D.new()
	line.width = width
	line.modulate = color
	parent.add_child( line )
	line.add_point( point )
	for ad in range( 0, 360, 4 ):
		var a = deg_to_rad( ad )
		var x = cos( a ) * radius + point.x
		var y = sin( a ) * radius + point.y
		line.add_point( Vector2( x, y ) )
	if fade > 0:
		var tween = create_tween()
		tween.tween_property( line, "modulate:a", 0, fade )
		await tween.finished
		if line != null:
			line.queue_free()


func debug_line( from: Vector2, to: Vector2, color: Color, width, parent: Node, fade: float = 0 ) -> void:
	if not is_debug: return
	var line = Line2D.new()
	line.width = width
	line.modulate = color
	parent.add_child( line )
	line.add_point( from )
	line.add_point( to )
	
	if fade > 0:
		var tween = create_tween()
		tween.tween_property( line, "modulate:a", 0, fade )
		await tween.finished
		if line != null:
			line.queue_free()


func save_settings() -> void:
	if is_loading_settings:
		return
	var exe_path = OS.get_executable_path()
	var file_path = exe_path.get_base_dir() + "/" + SETTINGS_FILE
	var settings: Dictionary = {
		"players": players, 
		"is_fullscreen": is_fullscreen,
		"language": LANGUAGES[ language_id ],
		"sound": AudioServer.get_bus_volume_db( AudioServer.get_bus_index( "Sound" ) ),
		"music": AudioServer.get_bus_volume_db( AudioServer.get_bus_index( "Music" ) )
	}
	var save_file = FileAccess.open( file_path, FileAccess.WRITE )
	save_file.store_line( JSON.stringify( settings ) )


func load_settings() -> void:
	var exe_path = OS.get_executable_path()
	var file_path = exe_path.get_base_dir() + "/" + SETTINGS_FILE
	if not FileAccess.file_exists( file_path ):
		return
	var load_file = FileAccess.open( file_path, FileAccess.READ )
	var json_string = load_file.get_as_text()
	load_file.close()
	var settings: Dictionary = JSON.parse_string( json_string )
	if settings == null:
		return
	if settings.has( "sound" ) and settings.sound is float:
		var db = clampf( settings.sound, -80, 16 )
		AudioServer.set_bus_volume_db( AudioServer.get_bus_index( "Sound" ), db )
	if settings.has( "music" ) and settings.music is float:
		var db = clampf( settings.music, -80, 16 )
		AudioServer.set_bus_volume_db( AudioServer.get_bus_index( "Music" ), db )
	if settings.has( "is_fullscreen" ) and settings.is_fullscreen is bool:
		is_fullscreen = settings.is_fullscreen
	if settings.has( "language" ) and settings.language is String:
		var id = LANGUAGES.find( settings.language )
		if id >= 0:
			language_id = id
	if settings.has( "players" ) and settings.players is Array:
		for i in range( settings.players.size() ):
			if i >= players.size():
				break
			var player = settings.players[ i ]
			if player is Dictionary:
				if player.has( "colors" ) and player.colors is float:
					if player.colors < PLAYER_COLORS.size():
						players[ i ].colors = floori( player.colors )
				if player.has( "controls" ) and player.controls is String:
					if CONTROL_NAMES.has( player.controls ):
						players[ i ].controls = player.controls
				if player.has( "enabled" ) and player.enabled is bool:
					players[ i ].enabled = player.enabled
				if player.has( "name" ) and player.name is String:
					if name.length() >= 16:
						players[ i ].name = player.name.substring( 0, 15 )
					else:
						players[ i ].name = player.name
				if player.has( "image_id" ) and player.image_id is float:
					if player.image_id < BLAST_IMAGES.size():
						players[ i ].image_id = floori( player.image_id )


func parse_field( data, data_type ):
	if data_type == "int":
		if data is float:
			return floori( data )
	if data_type == "float":
		if data is float:
			return data
	if data_type == "string":
		if data is String:
			return data
	if data_type == "bool":
		if data is bool:
			return data
	if data_type == "color":
		if data is String:
			return Color.from_string( data, Color.WHITE )
	if data_type == "colors":
		if data is Array:
			var arr = []
			for d in data:
				var val = parse_field( d, "color" )
				if val == null:
					return null
				arr.append( val )
			return arr
	return null


func store_field( data, data_type ):
	if data_type == "color":
		return data.to_html( true )
	if data_type == "colors":
		var arr = []
		for c in data:
			arr.append( c.to_html( true ) )
		return arr
	return data


func normalize_angle( angle: float ) -> float:
	return wrapf( angle, -PI, PI )
	##print( "Before: %s" % rad_to_deg( angle ) )
	#while angle < 0:
		#angle += TAU
	#while angle > TAU:
		#angle -= TAU
	##print( "After: %s" % rad_to_deg( angle ) )
	#return angle


func get_rotation_direction( angle_current: float, angle_target: float ) -> int:
	
	# Find the difference between the target and current angles
	var delta_angle = normalize_angle( angle_target - angle_current )
	
	# Determine the shortest direction to rotate
	if delta_angle > PI:
		# Clockwise rotation is shorter
		return -1
	else:
		# Counterclockwise rotation is shorter
		return 1
