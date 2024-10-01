extends Node
class_name TUN_Ground


const MIN_BORDER = 5
const MAX_BORDER = 35
const BORDER_START = 20
const GROUND_COLORS = [
	Color( 0.41, 0.26, 0.13 ),
	Color( 0.41, 0.26, 0.13 ),
	Color( 0.36, 0.22, 0.11 ),
	Color( 0.36, 0.22, 0.11 ),
	Color( 0.36, 0.22, 0.11 ),
	Color( 0.36, 0.22, 0.11 ),
	Color( 0.3, 0.15, 0.09 ),
	Color( 0.3, 0.15, 0.09 ),
]
const ROCK_COLORS: Array = [
	Color( 0.4, 0.4, 0.4 ),
	Color( 0.4, 0.4, 0.4 ),
	Color( 0.3, 0.3, 0.3 ),
	Color( 0.3, 0.3, 0.3 ),
	Color( 0.3, 0.3, 0.3 ),
	Color( 0.3, 0.3, 0.3 ),
	Color( 0.3, 0.3, 0.3 ),
	Color( 0.3, 0.3, 0.3 ),
	Color( 0.3, 0.3, 0.3 ),
	Color( 0.3, 0.3, 0.3 ),
	Color( 0.3, 0.3, 0.3 ),
	Color( 0.2, 0.2, 0.2 ),
	Color( 0.2, 0.2, 0.2 ),
]
const CAVE_COLORS: Array = [
	Color( 0.1, 0.1, 0.1 ),
	Color( 0.09, 0.09, 0.09 ),
	Color( 0.075, 0.075, 0.075 ),
	Color( 0.075, 0.075, 0.075 ),
	Color( 0.075, 0.075, 0.075 ),
]
const BASE_COLORS: Array = [
	Color( 0.12, 0.12, 0.12 ),
	Color( 0.13, 0.13, 0.13 ),
	Color( 0.1, 0.1, 0.1 ),
]
const ROCK_COLOR: Color = Color( 0.5, 0.5, 0.5 )
const BASE_DATA: Dictionary = {
	"width": 35,
	"height": 35,
	"walls": [
		# Top Left
		Rect2i( 3,   2,  9,  4 ),
		Rect2i( 2,   3,  4, 10 ),
		
		# Bottom Left
		Rect2i( 2,  22,  4, 10 ),
		Rect2i( 3,  29,  9,  4 ),
		
		# Bottom Right
		Rect2i( 23, 29,  9,  4 ),
		Rect2i( 29, 22,  4, 10 ),
		
		# Top Right
		Rect2i( 23,  2,  9,  4 ),
		Rect2i( 29,  3,  4, 10 )
	]
}
const TANK_SIZE: int = 10


var width: int = 170
var height: int = 170
var img_texture_zero: ImageTexture
var img_texture: ImageTexture
var img: Image
var img_zero: Image
var solid_colors: Array = [ ROCK_COLOR ]
var grid: AStarGrid2D
var base_colors: Array = []


func _ready() -> void:
	Tun.ground = self


func init( new_width: int, new_height: int ) -> void:
	solid_colors = [ ROCK_COLOR ]
	for c in ROCK_COLORS:
		if not is_solid_color( c ):
			solid_colors.append( c )
	width = new_width
	height = new_height
	img = Image.create( width, height, false, Image.FORMAT_RGB8 )
	img_texture = ImageTexture.create_from_image( img )
	img_zero = Image.create( width * 2, height * 2, false, Image.FORMAT_RGB8 )
	img_texture_zero = ImageTexture.create_from_image( img_zero )


func load( img_new: Image ) -> void:
	img = img_new
	img_texture.update( img )
	width = img.get_width()
	height = img.get_height()


func draw_dirt() -> void:
	for y in range( height ):
		for x in range( width ):
			var color = GROUND_COLORS.pick_random()
			img.set_pixel( x, y, color )


func draw_background_zero( bases: Array ) -> void:
	
	# Draw the caves and rocks
	for y in range( height * 2 ):
		for x in range( width * 2 ):
			var ix = x - ( float( width * 2 ) / 4.0 )
			var iy = y - ( float( height * 2 ) / 4.0 )
			if (
				ix > 0 and ix < width and iy > 0 and iy < height and
				not is_solid_color( img.get_pixel( ix, iy ) )
			):
				img_zero.set_pixel( x, y, CAVE_COLORS.pick_random() )
			else:
				img_zero.set_pixel( x, y, ROCK_COLORS.pick_random() )
	
	# Draw the base floor on background zero
	var bi = 0
	for base in bases:
		@warning_ignore( "integer_division" )
		var zx = base.position.x + ( width * 2 ) / 4
		@warning_ignore( "integer_division" )
		var zy = base.position.y + ( height * 2 ) / 4
		var zr = Rect2i( zx + 2, zy + 2, base.size.x - 4, base.size.y - 4 )
		#img_zero.fill_rect( zr, BASE_COLORS[ 0 ] )
		#img_zero.fill_rect( zr, Color.RED )
		var ci: int = 0
		var cx = zr.size.x / 2 + 3
		var cy = zr.size.y / 2 + 3
		var cs = []
		cs.append( base_colors[ bi ].darkened( 0.5 ) )
		cs.append( base_colors[ bi ].darkened( 0.6 ) )
		cs.append( base_colors[ bi ].darkened( 0.7 ) )
		for y in range( 3, zr.size.y, 3 ):
			for x in range( 3, zr.size.x, 3 ):
				var dx = x - cx + 1.5
				var dy = y - cy + 1.5
				var d = sqrt( dx * dx + dy * dy )
				#if d > 12:
				#	continue
					
				#var c = BASE_COLORS[ ci ]
				var c = cs[ ci ]
				if d >= 13:
					c = c.darkened( 0.4 )
				elif d >= 12:
					c = c.darkened( 0.35 )
				elif d >= 11:
					c = c.darkened( 0.3 )
				elif d >= 10:
					c = c.darkened( 0.25 )
				elif d >= 9:
					c = c.darkened( 0.2 )
				elif d >= 8:
					c = c.darkened( 0.15 )
				#var c = Color.GREEN
				img_zero.set_pixel( zx + x, zy + y, c )
				img_zero.set_pixel( zx + x, zy + y + 1, c )
				img_zero.set_pixel( zx + x, zy + y + 2, c )
				img_zero.set_pixel( zx + x + 1, zy + y, c )
				img_zero.set_pixel( zx + x + 1, zy + y + 1, c )
				img_zero.set_pixel( zx + x + 1, zy + y + 2, c )
				img_zero.set_pixel( zx + x + 2, zy + y, c )
				img_zero.set_pixel( zx + x + 2, zy + y + 1, c )
				img_zero.set_pixel( zx + x + 2, zy + y + 2, c )
				
				ci += 1
				if ci >= BASE_COLORS.size():
					ci = 0
		bi += 1


func draw_level( bases: Array, tanks: Array ) -> void:
	draw_dirt()
	draw_borders()
	draw_bases( tanks )
	draw_rocks()
	draw_background_zero( bases )
	img_texture_zero.update( img_zero )
	img_texture.update( img )


func draw_borders() -> void:
	
	# Draw Top Border
	var by = BORDER_START
	for x in range( width ):
		for y in range( 0, by ):
			if y == by - 1:
				img.set_pixel( x, y, ROCK_COLOR )
			else:
				img.set_pixel( x, y, ROCK_COLORS.pick_random() )
		by = clampi( by + randi_range( -1, 1 ), MIN_BORDER, MAX_BORDER )
	
	# Draw Bottom Border
	by = height - BORDER_START
	for x in range( width ):
		for y in range( by, height ):
			if y == by and not is_solid_color( img.get_pixel( x, y ) ):
				img.set_pixel( x, y, ROCK_COLOR )
			else:
				img.set_pixel( x, y, ROCK_COLORS.pick_random() )
		by = clampi( by + randi_range( -1, 1 ), height - MAX_BORDER, height - MIN_BORDER )
	
	# Draw Left Border
	var bx = BORDER_START
	for y in range( height ):
		for x in range( 0, bx ):
			if x == bx - 1 and not is_solid_color( img.get_pixel( x, y ) ):
				img.set_pixel( x, y, ROCK_COLOR )
			else:
				img.set_pixel( x, y, ROCK_COLORS.pick_random() )
				
		bx = clampi( bx + randi_range( -1, 1 ), MIN_BORDER, MAX_BORDER )
	
	# Draw Right Border
	bx = width - BORDER_START
	for y in range( height ):
		for x in range( bx, width ):
			if x == bx and not is_solid_color( img.get_pixel( x, y ) ):
				img.set_pixel( x, y, ROCK_COLOR )
			else:
				img.set_pixel( x, y, ROCK_COLORS.pick_random() )
		bx = clampi( bx + randi_range( -1, 1 ), width - MAX_BORDER, width - MIN_BORDER )


func draw_rocks() -> void:
	var num_rocks: int
	var min_width: int
	var max_width: int
	var min_height: int
	var max_height: int
	if Tun.settings.ROCKS == 0:
		return
	else:
		var rock_scale = Tun.settings.ROCKS
		var map_scale = Tun.settings.SIZE + 1
		num_rocks = 5 + 5 * rock_scale + 7 * map_scale
		min_width = 10 + 5 * rock_scale + 5 * map_scale
		max_width = 20 + 10 * rock_scale + 10 * map_scale
		min_height = 5 + 5 * rock_scale + 5 * map_scale
		max_height = 15 + 5 * rock_scale + 5 * map_scale
	var attempts = 0
	while num_rocks > 0 and attempts < 5000:
		attempts += 1
		if attempts % 500 == 499:
			max_width = clampi( max_width - 1, min_width, max_width )
			max_height = clampi( max_height - 1, min_height, max_height )
		if attempts % 1000 == 999:
			min_width = clampi( min_width - 1, 10, min_width )
			min_height = clampi( min_height - 1, 7, min_height )
			max_width = clampi( max_width - 1, min_width, max_width )
			max_height = clampi( max_height - 1, min_height, max_height )
		var size: Vector2 = Vector2(
			randf_range( min_width, max_width ),
			randf_range( min_height, max_height )
		)
		var pos: Vector2 = Vector2(
			randf_range( size.x, width - size.x ),
			randf_range( size.y, height - size.y )
		)
		var rect: Rect2 = Rect2( pos, size )
		var buff: Vector2 = size / 2
		var ch_rect: Rect2 = Rect2( pos - buff / 2, size + buff )
		var skip = false
		for y in range( ch_rect.position.y, ch_rect.position.y + ch_rect.size.y ):
			for x in range( ch_rect.position.x, ch_rect.position.x + ch_rect.size.x ):
				var c = img.get_pixel( x, y )
				if c == Color.BLACK or is_solid_color( c ):
					skip = true
					break
			if skip:
				break
		if skip:
			continue
		var rock_data = Globals.create_rock( rect, Vector2i( 5, 9 ) )
		Globals.draw_rock( img, rock_data, rect, ROCK_COLORS, ROCK_COLOR )
		num_rocks -= 1


func draw_bases( tanks: Array ) -> void:
	for i in range( tanks.size() ):
		var tank = tanks[ i ]
		var base = tank.base
		draw_base2( base )


func draw_base( base: Rect2i, c1: Color, c2: Color ) -> void:
	var t = Rect2i(
		base.position.x + 2,
		base.position.y + 2,
		base.size.x - 4,
		base.size.y - 4
	)
	img.fill_rect( t, Color.BLACK )
	for wall in BASE_DATA.walls:
		var w = Rect2i( base.position + wall.position, wall.size )
		img.fill_rect( w, c2 )
	
	for wall in BASE_DATA.walls:
		var w = Rect2i( base.position + wall.position, wall.size )
		t = Rect2i(
			w.position.x + 1,
			w.position.y + 1,
			w.size.x - 2,
			w.size.y - 2
		)
		img.fill_rect( t, c1 )


func draw_base2( base: Rect2i ) -> void:
	@warning_ignore( "integer_division" )
	var cx = base.position.x + base.size.x / 2
	@warning_ignore( "integer_division" )
	var cy = base.position.y + base.size.y / 2
	var r = 8
	Globals.draw_filled_circle( img, Color.BLACK, cx, cy, r )
	for i in range( 300 ):
		var r2 = randf_range( 8, randf_range( 10, 20 ) )
		var a = randf_range( 0, 360 )
		var rad = deg_to_rad( a )
		var x = cx + cos( rad ) * r2
		var y = cy + sin( rad ) * r2
		img.set_pixel( x, y, Color.BLACK )


func update() -> void:
	img_texture.update( img )


func get_random_base_rect() -> Rect2i:
	var min_x = MAX_BORDER + TANK_SIZE
	var max_x = width - ( min_x + BASE_DATA.width + TANK_SIZE )
	var min_y = MAX_BORDER + TANK_SIZE
	var max_y = height - ( min_y + BASE_DATA.height + TANK_SIZE )
	var rect: Rect2i = Rect2i(
		roundi( randf_range( min_x, max_x ) / Tun.GRID_SIZE ) * Tun.GRID_SIZE,
		roundi( randf_range( min_y, max_y ) / Tun.GRID_SIZE ) * Tun.GRID_SIZE,
		BASE_DATA.width,
		BASE_DATA.height
	)
	return rect


func is_solid_color( color: Color ) -> bool:
	if color == Color.BLACK:
		return false
	for solid_color: Color in solid_colors:
		var diff_r = color.r - solid_color.r
		var diff_g = color.g - solid_color.g
		var diff_b = color.b - solid_color.b
		var diff = ( diff_r * diff_r ) + ( diff_g * diff_g ) + ( diff_b * diff_b )
		if diff < 0.01:
			return true
	return false


func setup_grid() -> void:
	@warning_ignore( "integer_division" )
	var grid_width: int = floor( width / Tun.GRID_SIZE )
	@warning_ignore( "integer_division" )
	var grid_height: int = floor( height / Tun.GRID_SIZE )
	grid = AStarGrid2D.new()
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.region = Rect2i( 0, 0, grid_width, grid_height )
	grid.cell_size = Vector2( Tun.GRID_SIZE, Tun.GRID_SIZE )
	grid.update()
	for cell_y in range( grid_height ):
		for cell_x in range( grid_width ):
			update_grid_cell( cell_x, cell_y )
	if Globals.is_debug:
		print_grid()


func update_grid_cell( cell_x: int, cell_y: int ) -> void:
	var is_clear: bool = true
	var weight: float = 1
	for y in range( cell_y * Tun.GRID_SIZE, cell_y * Tun.GRID_SIZE + Tun.GRID_SIZE ):
		for x in range( cell_x * Tun.GRID_SIZE, cell_x * Tun.GRID_SIZE + Tun.GRID_SIZE ):
			var c = img.get_pixel( x, y )
			if is_solid_color( img.get_pixel( x, y ) ):
				is_clear = false
			if c != Color.BLACK:
				weight += 1
	if is_clear:
		var max_weight: float = Tun.GRID_SIZE * Tun.GRID_SIZE
		var weight_scale: float = max( weight / max_weight, 0.1 )
		grid.set_point_weight_scale( Vector2i( cell_x, cell_y ), weight_scale )
	grid.set_point_solid( Vector2i( cell_x, cell_y ), not is_clear )


func debug_update_grid_cell( cell_x: int, cell_y: int ) -> void:
	var is_solid = grid.is_point_solid( Vector2i( cell_x, cell_y ) )
	var c: Color = ROCK_COLOR
	if not is_solid:
		return
	
	for y in range( cell_y * Tun.GRID_SIZE, cell_y * Tun.GRID_SIZE + Tun.GRID_SIZE ):
		for x in range( cell_x * Tun.GRID_SIZE, cell_x * Tun.GRID_SIZE + Tun.GRID_SIZE ):
			img.set_pixel( x, y, c )


func update_grid_from_pixels( pixels: Array ) -> void:
	var cells: Dictionary = {}
	for i in range( pixels.size() ):
		var cell: Vector2i = Vector2i( pixels[ i ].x / Tun.GRID_SIZE, pixels[ i ].y / Tun.GRID_SIZE )
		cells[ cell ] = true
	
	for cell in cells.keys():
		update_grid_cell( cell.x, cell.y )


func print_grid() -> void:
	@warning_ignore( "integer_division" )
	var grid_width: int = floor( width / Tun.GRID_SIZE )
	@warning_ignore( "integer_division" )
	var grid_height: int = floor( height / Tun.GRID_SIZE )
	print( "Grid:" )
	for cell_y in range( grid_height ):
		var msg = ""
		for cell_x in range( grid_width ):
			if grid.is_point_solid( Vector2i( cell_x, cell_y ) ):
				msg += "X"
			else:
				var weight_scale: float = grid.get_point_weight_scale( Vector2i( cell_x, cell_y ) )
				if weight_scale < 1:
					msg += " "
				else:
					msg += "."
		print( msg )
