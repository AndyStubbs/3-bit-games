extends Node


const B_COLOR: Color = Color( 0.65, 0.65, 0.65 )
const ROCK_COLORS: Array = [ Color( 0.60, 0.60, 0.60 ) ]
const CRATER_COLORS: Array = [
	Color( 0.5, 0.5, 0.5 ),
	Color( 0.45, 0.45, 0.45 ),
	Color( 0.30, 0.30, 0.30 )
]
const CRATER_DENSITY = 250


func create_rock( rock_width: int, rock_height: int ) -> void:
	var rect: Rect2 = Rect2( 0, 0, rock_width, rock_height )
	var points = Globals.create_rock( rect, Vector2i( 10, 25 ), 0, 0.35 )
	var rock_image: Image = Image.create(
		roundi( rect.size.x ), roundi( rect.size.y ), false, Image.FORMAT_RGBA8
	)
	Globals.draw_rock( rock_image, points, rect, ROCK_COLORS, B_COLOR )
	
	# Draw craters
	var num_craters = roundi( ( rect.size.x * rect.size.y ) / CRATER_DENSITY )
	var min_width = rect.size.x / 6
	var min_height = rect.size.y / 6
	var max_width = rect.size.x / 3
	var max_height = rect.size.y / 3
	for i in range( num_craters ):
		var x = randi_range( 5, rock_image.get_width() - 5 )
		var y = randi_range( 5, rock_image.get_height() - 5 )
		var c_width = clampf( randi_range( 5, rect.size.x - x ), min_width, max_width )
		var c_height = clampf( randi_range( 5, rect.size.y - y ), min_height, max_height )
		var rct = Rect2( x, y, c_width, c_height )
		var skip = false
		for y2 in range( rct.position.y, rct.position.y + rct.size.y ):
			for x2 in range( rct.position.x, rct.position.x + rct.size.x ):
				if x2 >= rock_image.get_width() or y2 > rock_image.get_height():
					skip = true
				else:
					var c = rock_image.get_pixel( x2, y2 )
					if not Globals.are_colors_simular( c, ROCK_COLORS[ 0 ] ):
						skip = true
				if skip:
					break
			if skip:
				break
		if not skip:
			for c in CRATER_COLORS:
				if rct.size.x > 6 and rct.size.y > 0:
					var pts = Globals.create_rock( rct, Vector2i( 5, 15 ), 0, 0.45 )
					Globals.draw_rock( rock_image, pts, rct, [ c ], c )
					rct.position += Vector2( 3, 3 )
					rct.size -= Vector2( 6, 6 )
	save_rock( points, rock_image, rock_width, rock_height )



func save_rock( points: Array, image: Image, rock_width, rock_height ) -> void:
	var exe_path = OS.get_executable_path()
	var name_part = "/rocks/rock-" + str( randi_range( 0, 99999 ) )
	var file_name = exe_path.get_base_dir() + name_part
	#var file_name = "res://Games/Blastroids/Rocks/rock-" + str( randi_range( 0, 99999 ) )
	var save_file = FileAccess.open( file_name + ".json", FileAccess.WRITE )
	var data: Dictionary = {
		"width": rock_width,
		"height": rock_height,
		"points": [],
		"image": name_part + ".png"
	}
	for point in points:
		data.points.append( [ point.x, point.y ] )
	save_file.store_line( JSON.stringify( data ) )
	image.save_png( file_name + ".png" )


func _ready() -> void:
	for i in range( 100 ):
		create_rock( 200, 200 )
