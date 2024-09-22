extends Node


enum BULLET_TYPES {
	COPPER,
	IRON,
	GOLD,
	DIAMOND,
	SELF_GUIDED,
	SLIME,
	DIRT,
	BRIDGE,
	SHOVEL,
	CLUSTER,
	MINI_CLUSTER,
	BOUNCING,
	MINE,
	LASER,
	NUKE,
	ROCKET_BOOST,
	SUPER_NUKE,
	POTION
}

enum TERRAIN {
	ANY,
	MOUNTAIN,
	VALLEY,
	RANDOM1,
	RANDOM2,
	FLAT
}

const SETTINGS_FILE: String = "raf.json"
const SIZES: Array = [ 480, 640, 800 ]

const DIRT_COLORS = [
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

const SLIME_COLOR: Color = Color( 0.15, 0.8, 0.15 )
const MINI_CLUSTER_IMAGE = preload( "res://Games/ReadyAimFire/Images/mini_cluster.png" )
const BULLET_FIELDS: Dictionary = {
	"modulate": "color",
	#"text": "string",
	"freq": "int",
	"radius": "float",
	"force": "float",
	"points": "int",
	"explosion_scale": "float",
	"bullet_scale": "float",
	"type": "string",
	"bridge": "bool",
	"bouncing": "bool",
	"potion": "bool",
	"particle_count": "int",
	"particle_colors": "colors",
	"particle_pattern": "string",
	"cluster_distance": "float",
	"shovel": "bool"
}
const BULLET_DATA: Dictionary = {
	Raf.BULLET_TYPES.COPPER: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/copper_bullet.png" ),
		"image": preload( "res://Assets/Images/pixel.png" ),
		"modulate": Color( 1, 0.53, 0.25 ),
		"text": "TR_COPPER_BULLET",
		"freq": 8,
		"radius": 7,
		"force": 200,
		"points": 50,
		"explosion_scale": 1,
		"bullet_scale": 4,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.IRON: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/iron_bullet.png" ),
		"image": preload( "res://Assets/Images/pixel.png" ),
		"modulate": Color( 0.85, 0.85, 0.85 ),
		"text": "TR_IRON_BULLET",
		"freq": 8,
		"radius": 8,
		"force": 250,
		"points": 60,
		"explosion_scale": 1.15,
		"bullet_scale": 4,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.GOLD: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/gold_bullet.png" ),
		"image": preload( "res://Assets/Images/pixel.png" ),
		"modulate": Color( 1, 0.95, 0 ),
		"text": "TR_GOLD_BULLET",
		"freq": 8,
		"radius": 9,
		"force": 300,
		"points": 70,
		"explosion_scale": 1.3,
		"bullet_scale": 4,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.DIAMOND: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/diamond_bullet.png" ),
		"image": preload( "res://Assets/Images/pixel.png" ),
		"modulate": Color( 0.5, 0.9, 1.0 ),
		"text": "TR_DIAMOND_BULLET",
		"freq": 8,
		"radius": 10,
		"force": 350,
		"points": 80,
		"explosion_scale": 1.45,
		"bullet_scale": 4,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.SELF_GUIDED: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/ui_self_guided_missile.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/self_guided_missile.png" ),
		"modulate": Color.WHITE,
		"text": "TR_SELF_GUIDED",
		"freq": 6,
		"radius": 6,
		"force": 200,
		"points": 30,
		"explosion_scale": 0.9,
		"bullet_scale": 1,
		"type": "missile"
	},
	Raf.BULLET_TYPES.SLIME: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/ui_slime_bullet.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/ui_slime_bullet.png" ),
		"modulate": Color.WHITE,
		"text": "TR_SLIME_BULLET",
		"freq": 6,
		"particle_count": 25,
		"particle_colors": [ SLIME_COLOR ],
		"particle_pattern": "slime",
		"bullet_scale": 0.5,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.DIRT: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/ui_dirt_bullet.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/ui_dirt_bullet.png" ),
		"modulate": Color.WHITE,
		"text": "TR_DIRT_BULLET",
		"freq": 6,
		"particle_count": 500,
		"particle_colors": DIRT_COLORS,
		"particle_pattern": "dirt",
		"bullet_scale": 0.5,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.BRIDGE: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/ui_bridge_bullet.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/ui_bridge_bullet.png" ),
		"modulate": Color.WHITE,
		"text": "TR_BRIDGE_BULLET",
		"freq": 6,
		"bridge": true,
		"bullet_scale": 1,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.SHOVEL: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/ui_shovel.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/shovel.png" ),
		"modulate": Color.WHITE,
		"text": "TR_SHOVEL_BULLET",
		"freq": 8,
		"shovel": true,
		"bullet_scale": 1,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.CLUSTER: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/cluster.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/cluster.png" ),
		"modulate": Color.WHITE,
		"text": "TR_CLUSTER_BOMB",
		"freq": 6,
		"bullet_scale": 1,
		"type": "cluster",
		"cluster_distance": 15,
		"radius": 5,
		"force": 200,
		"points": 20,
		"explosion_scale": 0.8,
	},
	Raf.BULLET_TYPES.MINI_CLUSTER: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/mini_cluster.png" ),
		"image": MINI_CLUSTER_IMAGE,
		"modulate": Color.WHITE,
		"text": "TR_MINI_CLUSTER",
		"freq": 0,
		"bullet_scale": 1,
		"type": "bullet",
		"radius": 5,
		"force": 200,
		"points": 20,
		"explosion_scale": 0.8,
	},
	Raf.BULLET_TYPES.BOUNCING: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/bouncing_bomb.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/bouncing_bomb.png" ),
		"modulate": Color.WHITE,
		"text": "TR_BOUNCING",
		"freq": 6,
		"bullet_scale": 1,
		"type": "bullet",
		"bouncing": true,
		"radius": 7,
		"force": 250,
		"points": 50,
		"explosion_scale": 1
	},
	Raf.BULLET_TYPES.MINE: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/mine.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/mine.png" ),
		"modulate": Color.WHITE,
		"text": "TR_MINE",
		"freq": 6,
		"bullet_scale": 0.75,
		"type": "bullet",
		"mine": true,
		"radius": 7,
		"force": 300,
		"points": 50,
		"explosion_scale": 1
	},
	Raf.BULLET_TYPES.LASER: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/ui_laser.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/laser.png" ),
		"modulate": Color.WHITE,
		"text": "TR_LASER",
		"type": "laser",
		"freq": 6,
		"radius": 7,
		"force": 200,
		"points": 50,
		"bullet_scale": 1.0
	},
	Raf.BULLET_TYPES.NUKE: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/ui_nuke.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/nuke.png" ),
		"modulate": Color.WHITE,
		"text": "TR_NUKE",
		"freq": 2,
		"radius": 45,
		"force": 750,
		"points": 150,
		"explosion_scale": 2,
		"bullet_scale": 1.5,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.ROCKET_BOOST: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/ui_rockets.png" ),
		"text": "TR_ROCKET_BOOSTER",
		"freq": 6,
		"type": "booster"
	},
	Raf.BULLET_TYPES.SUPER_NUKE: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/ui_super_nuke.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/super_nuke.png" ),
		"modulate": Color.WHITE,
		"text": "TR_SUPER_NUKE",
		"freq": 1,
		"radius": 100,
		"force": 1000,
		"points": 300,
		"explosion_scale": 2,
		"bullet_scale": 1.5,
		"type": "bullet"
	},
	Raf.BULLET_TYPES.POTION: {
		"ui_image": preload( "res://Games/ReadyAimFire/Images/potion.png" ),
		"image": preload( "res://Games/ReadyAimFire/Images/potion.png" ),
		"modulate": Color( 1, 1, 1 ),
		"text": "TR_GROWTH_POTION",
		"freq": 4,
		"potion": true,
		"radius": 20,
		"force": 0,
		"points": 0,
		"explosion_scale": 1,
		"bullet_scale": 0.75,
		"type": "bullet"
	}
}

const TUTORIAL_TEXT: Array = [ [
		"TR_MOVEMENT_C",
		"TR_TUT_A_1",
		"TR_TUT_A_2",
	], [
		"TR_FIRING_C",
		"TR_TUT_B_1",
		"TR_TUT_B_2",
		"TR_TUT_B_3",
		"TR_TUT_B_4",
		"TR_TUT_B_5"
	], [
		"TR_BULLET_SEL",
		"TR_TUT_C_1",
		"TR_TUT_C_2",
		"TR_TUT_C_3",
		"TR_TUT_C_4"
	]
]

var scenes: Dictionary = {
	"menu": load( "res://Games/ReadyAimFire/Scenes/menu.tscn" ),
	"game": load( "res://Games/ReadyAimFire/Scenes/game.tscn" )
}

var bullet_data: Dictionary = {}
var shots: int = 9
var level_size: int = 0
var is_easy_targeting: bool = true
var is_tutorial: bool = false
var is_paused: bool = false
var ammo: Array = [
	BULLET_TYPES.COPPER,
	BULLET_TYPES.IRON,
	BULLET_TYPES.GOLD,
	BULLET_TYPES.DIAMOND,
	BULLET_TYPES.SELF_GUIDED,
	BULLET_TYPES.SLIME,
	BULLET_TYPES.DIRT,
	BULLET_TYPES.BRIDGE,
	BULLET_TYPES.SHOVEL,
	BULLET_TYPES.CLUSTER,
	BULLET_TYPES.BOUNCING,
	BULLET_TYPES.MINE,
	BULLET_TYPES.LASER,
	BULLET_TYPES.NUKE,
	BULLET_TYPES.ROCKET_BOOST,
	#BULLET_TYPES.SUPER_NUKE,
	BULLET_TYPES.POTION
]
var ammo_all: Array = [
	BULLET_TYPES.COPPER,
	BULLET_TYPES.IRON,
	BULLET_TYPES.GOLD,
	BULLET_TYPES.DIAMOND,
	BULLET_TYPES.SELF_GUIDED,
	BULLET_TYPES.SLIME,
	BULLET_TYPES.DIRT,
	BULLET_TYPES.BRIDGE,
	BULLET_TYPES.SHOVEL,
	BULLET_TYPES.CLUSTER,
	BULLET_TYPES.BOUNCING,
	BULLET_TYPES.MINE,
	BULLET_TYPES.LASER,
	BULLET_TYPES.NUKE,
	BULLET_TYPES.ROCKET_BOOST,
	BULLET_TYPES.SUPER_NUKE,
	BULLET_TYPES.POTION
]
var explosions: Dictionary = {}
var terrain_type: TERRAIN = TERRAIN.ANY
var movement_points: float = 10
var is_loading_settings: bool = false


signal on_ammo_updated


func _ready() -> void:
	is_loading_settings = true
	reset_all_bullet_data()
	load_settings()
	is_loading_settings = false
	Globals.on_language_changed.connect( on_language_changed )


func on_language_changed() -> void:
	for bullet in bullet_data:
		bullet_data[ bullet ].text = tr( BULLET_DATA[ bullet ].text )


func reset_all_bullet_data() -> void:
	for i in BULLET_DATA:
		reset_bullet_data( i )
	save_settings()


func reset_bullet_data( index: int ) -> void:
	var data = BULLET_DATA[ index ]
	bullet_data[ index ] = {}
	for d in data:
		if d == "text":
			bullet_data[ index ][ d ] = tr( data[ d ] )
		else:
			bullet_data[ index ][ d ] = data[ d ]
	save_settings()


func update_ammo( bullet_type: BULLET_TYPES, is_added: bool ) -> void:
	if is_added:
		if not ammo.find( bullet_type ) > -1:
			ammo.append( bullet_type )
	else:
		ammo.erase( bullet_type )
	ammo.sort()
	save_settings()
	on_ammo_updated.emit()


func clear_ammo() -> void:
	ammo = []
	save_settings()
	on_ammo_updated.emit()


func select_all_ammo() -> void:
	ammo = []
	ammo.append_array( ammo_all )
	save_settings()
	on_ammo_updated.emit()


func init_explosions( step: Signal ) -> void:
	for i in bullet_data:
		var data: Dictionary = bullet_data[ i ]
		if data.has( "radius" ):
			var r: int = data.radius
			if explosions.has( str( r ) ):
				continue
			var width: int = r * 2
			var image: Image = Image.create( width, width, false, Image.FORMAT_RGB8 )
			var mask: Image = Image.create( width, width, false, Image.FORMAT_RGBA8 )
			var rect: Rect2i = Rect2i( 0, 0, width, width )
			image.fill( Color.WHITE )
			mask.fill( Color( 0, 0, 0, 0 ) )
			Globals.draw_filled_circle( image, Color.BLACK, r, r, r )
			Globals.draw_filled_circle( mask, Color.BLACK, r, r, r )
			explosions[ str( r ) ] = {
				"image": image,
				"mask": mask,
				"rect": rect
			}
			await step


func save_settings() -> void:
	if is_loading_settings:
		return
	var exe_path = OS.get_executable_path()
	var file_path = exe_path.get_base_dir() + "/" + SETTINGS_FILE
	var data = {}
	for bullet in bullet_data:
		var data_row = {}
		var row: Dictionary = bullet_data[ bullet ]
		for d in row:
			if BULLET_FIELDS.has( d ):
				data_row[ d ] = Globals.store_field( row[ d ], BULLET_FIELDS[ d ] )
		data[ bullet ] = data_row
	var settings: Dictionary = {
		"ammo": ammo,
		"bullet_data": data,
		"level_size": level_size,
		"shots": shots,
		"terrain_type": terrain_type,
		"bonus_sights": is_easy_targeting
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
	ammo = []
	if settings.has( "level_size" ):
		level_size = Globals.parse_field( settings.level_size, "int" )
		level_size = clampi( level_size, 0, SIZES.size() - 1 )
	if settings.has( "shots" ):
		shots = Globals.parse_field( settings.shots, "int" )
		if shots == null:
			shots = 9
	if settings.has( "terrain_type" ):
		var ti = Globals.parse_field( settings.terrain_type, "int" )
		if ti < TERRAIN.size():
			terrain_type = ti
		else:
			terrain_type = TERRAIN.ANY
	if settings.has( "bonus_sights" ):
		is_easy_targeting = Globals.parse_field( settings.bonus_sights, "bool" )
	if settings.has( "ammo" ):
		for a in settings.ammo:
			if a is float and a < BULLET_TYPES.size():
				update_ammo( floori( a ), true )
	if settings.has( "bullet_data" ) and settings.bullet_data is Dictionary:
		for bullet in settings.bullet_data:
			if not bullet.is_valid_int():
				continue
			var bi = int( bullet  )
			if bi >= BULLET_TYPES.size():
				continue
			if bullet_data.has( bi ):
				var data = settings.bullet_data[ bullet ]
				for d in data:
					if bullet_data[ bi ].has( d ) and BULLET_FIELDS.has( d ):
						bullet_data[ bi ][ d ] = Globals.parse_field(
							data[ d ], BULLET_FIELDS[ d ]
						)
