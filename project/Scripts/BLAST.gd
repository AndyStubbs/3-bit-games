extends Node


const MAP_SIZES: Array = [
	Rect2( -1920, -1080, 3840, 2160 ),
	Rect2( -3840, -2160, 7680, 6480 ),
	Rect2( -5760, -6480, 11520, 10000 ),
	Rect2( -8000, -6000, 16000, 12000 ),
	Rect2( -15000, -7500, 30000, 15000 )
]
const ROCKS: Array = [
	[ 0,   3,  6,   9,  12,  15 ],
	[ 0,   6,  9,  12,  15,  18 ],
	[ 0,   6,  9,  12,  15,  18 ],
	[ 0,   6,  9,  12,  15,  18 ],
	[ 0,   6,  9,  12,  15,  18 ],
]

var scenes: Dictionary = {
	"menu": load( "res://Games/Blastroids/Scenes/blast_menu.tscn" ),
	"game": load( "res://Games/Blastroids/Scenes/blast_game.tscn" )
}
var rock_names: Dictionary
var settings: Dictionary = {
	"map_size": 2,
	"map_type": 0,
	"rock_density": 2,
	"crate_density": 2,
	"lives_count": 3
}


func get_num_rocks() -> int:
	return ROCKS[ settings.map_size ][ settings.rock_density ]


func get_rect() -> Rect2:
	var rect: Rect2 = Rect2( -1920, -1080, 3840, 2160 )
	var mult = ( settings.map_size + 1 )
	return Rect2( rect.position * mult, rect.size * mult )


func set_camera_limits( camera: Camera2D, buffer: int ) -> void:
	var rect: Rect2 = settings.rect
	camera.limit_left = roundi( rect.position.x ) + buffer
	camera.limit_right = roundi( rect.position.x + rect.size.x ) #- roundi( float( buffer ) / 2 )
	camera.limit_top = roundi( rect.position.y ) + buffer
	camera.limit_bottom = roundi( rect.position.y + rect.size.y ) - buffer


func _ready() -> void:
	var file_name = "res://Games/Blastroids/Rocks/rocks.json"
	var load_file = FileAccess.open( file_name, FileAccess.READ )
	var json_string = load_file.get_as_text()
	rock_names = JSON.parse_string( json_string )
