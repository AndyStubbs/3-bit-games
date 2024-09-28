extends Node


const SETTINGS_FILE: String = "blast.json"
const MAP_SIZES: Array = [
	Rect2( -1920, -1080, 3840, 2160 ),
	Rect2( -3840, -2160, 7680, 6480 ),
	Rect2( -5760, -6480, 11520, 10000 ),
	Rect2( -8000, -6000, 16000, 12000 ),
	Rect2( -15000, -7500, 30000, 15000 )
]
const ROCKS: Array = [
	[ 0,   6,  12,  27,  50 ],
	[ 0,  12,  30,  60, 120 ],
	[ 0,  30,  60, 120, 220 ],
	[ 0,  50, 100, 150, 300 ],
	[ 0,  80, 150, 300, 500 ],
]
const MAP_TYPES: Array = [ 0, 1, 2 ]
const CRATES: Array = [
	[ 0,   3,   6,   9,  12 ],
	[ 0,   6,   9,  12,  15 ],
	[ 0,   9,  12,  15,  20 ],
	[ 0,  12,  15,  20,  30 ],
	[ 0,  15,  20,  30,  50 ],
]
const LIVES: Array = [ 1, 2, 3, 4, 5, 6, 7 ]
const CROSSHAIRS: Array = [ false, true ]
const GAME_MODES: Array = [ "default", "race" ]


var is_loading_settings: bool = false
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
	"lives_count": 2,
	"added_cpus": 0,
	"game_mode": 0,
	"show_crosshairs": 1
}
var data: Dictionary = {
	"player_count": 0,
	"is_tutorial": false,
	"settings": {}
}


func get_num_rocks() -> int:
	return ROCKS[ settings.map_size ][ settings.rock_density ]


func get_num_crates() -> int:
	return CRATES[ settings.map_size ][ settings.crate_density ]


func get_rect() -> Rect2:
	var rect: Rect2 = Rect2( -1920, -1080, 3840, 2160 )
	if settings.map_type > 0:
		rect = Rect2( -1920, -1920, 3840, 3840 )
	var mult = ( settings.map_size + 1 )
	if settings.map_type == 2:
		mult += 2
	return Rect2( rect.position * mult, rect.size * mult )


func save_settings() -> void:
	if is_loading_settings:
		return
	var exe_path = OS.get_executable_path()
	var file_path = exe_path.get_base_dir() + "/" + SETTINGS_FILE
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
	var loaded_settings: Dictionary = JSON.parse_string( json_string )
	if loaded_settings == null:
		return
	if loaded_settings.has( "map_size" ):
		var map_size = Globals.parse_field( loaded_settings.map_size, "int" )
		settings.map_size = clampi( map_size, 0, MAP_SIZES.size() - 1 )
	if loaded_settings.has( "map_type" ):
		var map_type = Globals.parse_field( loaded_settings.map_type, "int" )
		settings.map_type = clampi( map_type, 0, MAP_TYPES.size() - 1 )
	if loaded_settings.has( "rock_density" ):
		var rock_density = Globals.parse_field( loaded_settings.rock_density, "int" )
		settings.rock_density = clampi( rock_density, 0, ROCKS.size() - 1 )
	if loaded_settings.has( "crate_density" ):
		var crate_density = Globals.parse_field( loaded_settings.crate_density, "int" )
		settings.crate_density = clampi( crate_density, 0, CRATES.size() - 1 )
	if loaded_settings.has( "lives_count" ):
		var lives_count = Globals.parse_field( loaded_settings.lives_count, "int" )
		settings.lives_count = clampi( lives_count, 0, LIVES.size() - 1 )
	if loaded_settings.has( "show_crosshairs" ):
		var index = Globals.parse_field( loaded_settings.show_crosshairs, "int" )
		settings.show_crosshairs = clampi( index, 0, CROSSHAIRS.size() - 1 )


func _ready() -> void:
	is_loading_settings = true
	var file_name = "res://Games/Blastroids/Rocks/rocks.json"
	var load_file = FileAccess.open( file_name, FileAccess.READ )
	var json_string = load_file.get_as_text()
	rock_names = JSON.parse_string( json_string )
	load_settings()
	is_loading_settings = false
