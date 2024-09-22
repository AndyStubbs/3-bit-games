extends Node


enum SPRITE_TYPES { ZERO, BACKGROUND, MINIMAP, MINIMAP_B }


@warning_ignore( "unused_signal" )
signal on_sprite_ready( sprite: Sprite2D, sprite_type: SPRITE_TYPES )

@warning_ignore( "unused_signal" )
signal on_tank_ready( tank: TUN_Tank )

@warning_ignore( "unused_signal" )
signal on_tank_moved( tank: TUN_Tank )

@warning_ignore( "unused_signal" )
signal on_bullet_moved( bullet: TUN_Bullet )

@warning_ignore( "unused_signal" )
signal on_pixel_moved( pixel: TUN_Pixel )

@warning_ignore( "unused_signal" )
signal on_bullet_fired( bullet: TUN_Bullet )

@warning_ignore( "unused_signal" )
signal on_energy_changed( tank: TUN_Tank )

@warning_ignore( "unused_signal" )
signal on_shields_changed( tank: TUN_Tank )

@warning_ignore( "unused_signal" )
signal on_tank_destroyed( tank: TUN_Tank )

@warning_ignore( "unused_signal" )
signal on_score_changed( score: int )

@warning_ignore( "unused_signal" )
signal on_player_select_updated()

@warning_ignore( "unused_signal" )
signal on_grid_path_generated( path: Array )


const SIZES: Array = [
	[ "Small", 512, 256 ],
	[ "Normal", 640, 384 ],
	[ "Large", 896, 640 ],
]
const MAX_PLAYERS: Array = [ 12, 16, 32 ]
const SCORES: Array = [ 1, 2, 3, 4, 5, 6, 7 ]
const ADD_CPUS: Array = [ 0, 1, 2, 3, 4, 5, 6 ]
const IMG_TANK_BODY = preload( "res://Games/TunnelTanks/Images/tanks.png" )
const IMG_TANK_COLLISION = preload( "res://Games/TunnelTanks/Images/tanks_collision.png" )
const IMG_TANK_DIG = preload( "res://Games/TunnelTanks/Images/tanks_dig.png" )
const IMG_TANK_STARTS: Dictionary = {
	"N": Vector2i( 0, 0 ),
	"NE": Vector2i( 10, 0 ),
	"E": Vector2i( 20, 0 ),
	"SE": Vector2i( 0, 10 ),
	"S": Vector2i( 10, 10 ),
	"SW": Vector2i( 20, 10 ),
	"W": Vector2i( 0, 20 ),
	"NW": Vector2i( 10, 20 )
}
const BULLET: Dictionary = {
	"N": {
		"RAD": 0,
		"OFFSET": Vector2( 4, 1 ),
		"SPRITE_OFFSET": Vector2( -1, -2 ),
		"VELOCITY": Vector2( 0, -1 )
	},
	"NE": {
		"RAD": PI / 4,
		"OFFSET": Vector2( 7, 1 ),
		"SPRITE_OFFSET": Vector2( -2, -1 ),
		"VELOCITY": Vector2( 1, -1 )
	},
	"E": {
		"RAD": PI / 2,
		"OFFSET": Vector2( 8, 4 ),
		"SPRITE_OFFSET": Vector2( -2, -2 ),
		"VELOCITY": Vector2( 1, 0 )
	},
	"SE": {
		"RAD": PI - PI / 4,
		"OFFSET": Vector2( 4, 4 ),
		"SPRITE_OFFSET": Vector2( 1, 1 ),
		"VELOCITY": Vector2( 1, 1 )
	},
	"S": {
		"RAD": PI,
		"OFFSET": Vector2( 4, 8 ),
		"SPRITE_OFFSET": Vector2( -1, -2 ),
		"VELOCITY": Vector2( 0, 1 )
	},
	"SW": {
		"RAD": PI + PI / 4,
		"OFFSET": Vector2( 2, 6 ),
		"SPRITE_OFFSET": Vector2( -2, -1 ),
		"VELOCITY": Vector2( -1, 1 )
	},
	"W": {
		"RAD": ( 3 * PI ) / 2,
		"OFFSET": Vector2( 0, 4 ),
		"SPRITE_OFFSET": Vector2( -1, -2 ),
		"VELOCITY": Vector2( -1, 0 )
	},
	"NW": {
		"RAD": TAU - PI / 4,
		"OFFSET": Vector2( 2, 2 ),
		"SPRITE_OFFSET": Vector2( -2, -2 ),
		"VELOCITY": Vector2( -1, -1 )
	}
}
const SETTINGS_FILE: String = "tun.json"
const ZOOM: Array = [ 6, 6 ]
const GRID_SIZE: int = 7
const SPEEDS: Array = [ 0, 1, 2 ]
const ROCKS: Array = [ 0, 1, 2, 3 ]


var settings = {
	"SPEED": 1,
	"SIZE": 1,
	"ROCKS": 0,
	"SCORE": 2,
	"ADD_CPUS": 0
}
var scenes: Dictionary = {
	"menu": load( "res://Games/TunnelTanks/Scenes/tun_menu.tscn" ),
	"game": load( "res://Games/TunnelTanks/Scenes/tun_game.tscn" )
}
var game_data: Dictionary = {
	"bullet_count": 0,
	"tank_count": 0,
	"tanks": []
}
var bullet_count: int = 0
var tank_count: int = 0
var tank_data: Dictionary = {}
var is_loading_settings = true
var ground: TUN_Ground


func _ready() -> void:
	var img_size: Vector2i = Vector2i( 10, 10 )
	for dir: String in IMG_TANK_STARTS.keys():
		var start: Vector2i = IMG_TANK_STARTS[ dir ]
		tank_data[ dir ] = Globals.get_image_data( IMG_TANK_BODY.get_image(), start, img_size )
		tank_data[ "collision_" + dir ] = Globals.get_image_data(
			IMG_TANK_COLLISION.get_image(), start, img_size
		)
		tank_data[ "dig_" + dir ] = Globals.get_image_data(
			IMG_TANK_DIG.get_image(), start, img_size
		)
	load_settings()


func save_settings() -> void:
	if is_loading_settings:
		return
	var exe_path = OS.get_executable_path()
	var file_path = exe_path.get_base_dir() + "/" + SETTINGS_FILE
	var save_file = FileAccess.open( file_path, FileAccess.WRITE )
	var line = JSON.stringify( settings )
	save_file.store_line( line )


func load_settings() -> void:
	is_loading_settings = true
	var exe_path = OS.get_executable_path()
	var file_path = exe_path.get_base_dir() + "/" + SETTINGS_FILE
	if not FileAccess.file_exists( file_path ):
		is_loading_settings = false
		return
	var load_file = FileAccess.open( file_path, FileAccess.READ )
	var json_string = load_file.get_as_text()
	load_file.close()
	var loaded_settings: Dictionary = JSON.parse_string( json_string )
	if loaded_settings == null:
		is_loading_settings = false
		return
	if loaded_settings.has( "SPEED" ):
		settings.SPEED = clampi(
			Globals.parse_field( loaded_settings.SPEED, "int" ), 0, SPEEDS.size() - 1
		)
	if loaded_settings.has( "SIZE" ):
		settings.SIZE = clampi(
			Globals.parse_field( loaded_settings.SIZE, "int" ), 0, SIZES.size() - 1
		)
	if loaded_settings.has( "ROCKS" ):
		settings.ROCKS = clampi(
			Globals.parse_field( loaded_settings.ROCKS, "int" ), 0, ROCKS.size() - 1
		)
	if loaded_settings.has( "ADD_CPUS" ):
		settings.ADD_CPUS = clampi(
			Globals.parse_field( loaded_settings.ADD_CPUS, "int" ), 0, ADD_CPUS.size() - 1
		)
	if loaded_settings.has( "SCORE" ):
		settings.SCORE = clampi(
			Globals.parse_field( loaded_settings.SCORE, "int" ), 0, SCORES.size() - 1
		)
	is_loading_settings = false
