extends Node
class_name BlastGame


enum WEAPONS {
	LASER, MASS, MISSILE, SPREAD, CHARGE, BOMB
}


const BUFFER = 1000
const BORDER_SHADER = preload( "res://Games/Blastroids/Scripts/v_drops.gdshader" )
const MINIMAP_SHADER = preload( "res://Shaders/outline.gdshader" )
const EXPLOSION_SCENE = preload( "res://Games/Blastroids/Scenes/blast_explosion.tscn" )
const LASER_IMAGE = preload( "res://Games/Blastroids/Images/blast_laser.png" )
const LASER_PICKUP_IMAGE = preload( "res://Games/Blastroids/Images/blast_laser_pickup.png" )
const LASER_SCENE = preload( "res://Games/Blastroids/Scenes/blast_laser.tscn" )
const LASER_UI_IMAGE = preload( "res://Games/Blastroids/Images/ui_blast_laser.png" )
const LASER_UI_MARKER = preload( "res://Games/Blastroids/Images/ui_blast_laser_markers.png" )
const CHARGE_UI_IMAGE = preload( "res://Games/Blastroids/Images/ui_blast_charge.png" )
const CHARGE_UI_MARKER = preload( "res://Games/Blastroids/Images/ui_blast_charge_markers.png" )
const CHARGE_IMAGE = preload( "res://Games/Blastroids/Images/blast_charge.png" )
const CHARGE_PICKUP = preload( "res://Games/Blastroids/Images/blast_charge_pickup.png" )
const SPREAD_UI_IMAGE = preload( "res://Games/Blastroids/Images/ui_blast_spread.png" )
const SPREAD_UI_MARKER = preload( "res://Games/Blastroids/Images/ui_blast_spread_markers.png" )
const SPREAD_PICKUP = preload( "res://Games/Blastroids/Images/blast_spread_pickup.png" )
const MASS_IMAGE = preload( "res://Games/Blastroids/Images/blast_mass.png" )
const MASS_PICKUP_IMAGE = preload( "res://Games/Blastroids/Images/blast_mass_pickup.png" )
const MASS_UI_MARKER = preload( "res://Games/Blastroids/Images/ui_blast_mass_markers.png" )
const MISSILE_BODY_SCENE = preload( "res://Games/Blastroids/Scenes/blast_missile_body.tscn" )
const MISSILE_SCENE = preload( "res://Games/Blastroids/Scenes/blast_missile.tscn" )
const MISSILE_UI_IMAGE = preload( "res://Games/ReadyAimFire/Images/ui_self_guided_missile.png" )
const MISSILE_UI_MARKER = preload( "res://Games/Blastroids/Images/ui_blast_missile_markers.png" )
const MISSILE_IMAGE = preload( "res://Games/ReadyAimFire/Images/self_guided_missile.png" )
const MISSILE_MARKER = preload( "res://Games/Blastroids/Images/blast_missile_markers.png" )
const MISSILE_PICKUP_IMAGE = preload( "res://Games/Blastroids/Images/blast_missile_pickup.png" )
const BOMB_UI_IMAGE = preload( "res://Games/Blastroids/Images/ui_blast_bomb.png" )
const BOMB_UI_MARKER = preload( "res://Games/Blastroids/Images/ui_blast_bomb_markers.png" )
const BOMB_PICKUP_IMAGE = preload( "res://Games/Blastroids/Images/blast_bomb_pickup.png" )
const BOMB_MARKER = preload( "res://Games/Blastroids/Images/blast_bomb_markers.png" )
const PICKUP_SCENE = preload( "res://Games/Blastroids/Scenes/blast_pickup.tscn" )
const ROCK_SCENE = preload( "res://Games/Blastroids/Scenes/blast_rock_body.tscn" )
const CRATE_SCENE = preload( "res://Games/Blastroids/Scenes/blast_crate.tscn" )
const SHIP_SCENE = preload( "res://Games/Blastroids/Scenes/blast_ship.tscn" )
const TRI_IMAGE = preload( "res://Games/Blastroids/Images/triangle.png" )
const TRI_IMAGE_BACK = preload( "res://Games/Blastroids/Images/triangle_back.png" )
const BORDER_SCENE = preload( "res://Games/Blastroids/Scenes/blast_border.tscn" )
const PLANET_SCENE = preload( "res://Games/Blastroids/Scenes/blast_planet.tscn" )
const WEAPONS_DATA: Dictionary = {
	WEAPONS.LASER: {
		"SCENE": LASER_SCENE,
		"PICKUP_IMAGE": LASER_PICKUP_IMAGE,
		"UI_IMAGE": LASER_UI_IMAGE,
		"UI_MARKER": LASER_UI_MARKER,
		"IMAGE": LASER_IMAGE,
		"TYPE": "energy",
		"AMMO_TYPE": "energy",
		"MASS": 0,
		"DAMAGE": 50,
		"COOLDOWN": 150,
		"DRAIN": 2000,
		"SPIN": 0,
		"SPEED": 1000,
		"SCALE": Vector2( 2, 2 )
	},
	WEAPONS.MASS: {
		"SCENE": LASER_SCENE,
		"PICKUP_IMAGE": MASS_PICKUP_IMAGE,
		"UI_IMAGE": LASER_UI_IMAGE,
		"UI_MARKER": MASS_UI_MARKER,
		"IMAGE": MASS_IMAGE,
		"TYPE": "energy",
		"AMMO_TYPE": "energy",
		"MASS": 1000,
		"DAMAGE": 25,
		"COOLDOWN": 300,
		"DRAIN": 3000,
		"SPIN": 50,
		"SPEED": 500,
		"SCALE": Vector2( 1.5, 1.5 )
	},
	WEAPONS.MISSILE: {
		"SCENE": MISSILE_BODY_SCENE,
		"PICKUP_IMAGE": MISSILE_PICKUP_IMAGE,
		"UI_IMAGE": MISSILE_UI_IMAGE,
		"UI_MARKER": MISSILE_UI_MARKER,
		"IMAGE": MISSILE_PICKUP_IMAGE,
		"MARKER": MISSILE_MARKER,
		"TYPE": "missile",
		"EXPLOSION_SCALE": Vector2( 2, 2 ),
		"AMMO_TYPE": "physical",
		"ENERGY": 1000,
		"MASS": 1,
		"COUNT": 6,
		"DAMAGE": 300,
		"COOLDOWN": 500,
		"DRAIN": 1,
		"SPIN": 0,
		"SPEED": 100,
		"SCALE": Vector2( 1, 1 )
	},
	WEAPONS.SPREAD: {
		"SCENE": LASER_SCENE,
		"PICKUP_IMAGE": SPREAD_PICKUP,
		"UI_IMAGE": SPREAD_UI_IMAGE,
		"UI_MARKER": SPREAD_UI_MARKER,
		"IMAGE": LASER_IMAGE,
		"TYPE": "spread",
		"AMMO_TYPE": "energy",
		"MASS": 0,
		"DAMAGE": 30,
		"COOLDOWN": 200,
		"DRAIN": 4000,
		"SPIN": 0,
		"SPEED": 1000,
		"SCALE": Vector2( 2, 2 )
	},
	WEAPONS.CHARGE: {
		"SCENE": LASER_SCENE,
		"PICKUP_IMAGE": CHARGE_PICKUP,
		"UI_IMAGE": CHARGE_UI_IMAGE,
		"UI_MARKER": CHARGE_UI_MARKER,
		"IMAGE": CHARGE_IMAGE,
		"TYPE": "charge",
		"AMMO_TYPE": "energy",
		"MASS": 0,
		"DAMAGE": 50,
		"COOLDOWN": 150,
		"DRAIN": 0,
		"CHARGE_DRAIN": 125,
		"SPIN": 0,
		"SPEED": 500,
		"SCALE": Vector2( 1, 1 )
	},
	WEAPONS.BOMB: {
		"SCENE": MISSILE_BODY_SCENE,
		"PICKUP_IMAGE": BOMB_PICKUP_IMAGE,
		"UI_IMAGE": BOMB_UI_IMAGE,
		"UI_MARKER": BOMB_UI_MARKER,
		"IMAGE": BOMB_PICKUP_IMAGE,
		"MARKER": BOMB_MARKER,
		"TYPE": "bomb",
		"EXPLOSION_SCALE": Vector2( 10, 10 ),
		"ENERGY": 500,
		"AMMO_TYPE": "physical",
		"MASS": 5,
		"COUNT": 1,
		"DAMAGE": 1200,
		"COOLDOWN": 1000,
		"DRAIN": 1,
		"SPIN": 0,
		"SPEED": 100,
		"SCALE": Vector2( 1, 1 )
	}
}


var worlds: Array
var uis: Array
var ships: Array = []
var minimaps: Array = []
var ui_items: Array = []
var planets: Array = []


@onready var bodies = $CanvasLayer/SubViewportContainer/WorldViewport/World/Bodies
@onready var pickup_sound = $Sounds/PickupSound


func init() -> void:
	ui_items.append( get_node( "Players/PL/HB/ColorRect" ) )
	var rock_sizes: Array = []
	rock_sizes.append_array( fill_array( "huge", 5 ) )
	rock_sizes.append_array( fill_array( "large", 4 ) )
	rock_sizes.append_array( fill_array( "medium", 3 ) )
	rock_sizes.append_array( fill_array( "small", 3 ) )
	rock_sizes.append_array( fill_array( "tiny", 3 ) )
	
	var rect: Rect2 = Blast.get_rect()
	
	# Create left borders
	var border_left: BlastBorder = BORDER_SCENE.instantiate()
	border_left.rect = Rect2(
		rect.position.x - BUFFER,
		rect.position.y - BUFFER,
		BUFFER,
		rect.size.y + BUFFER * 2
	)
	border_left.gravity = Vector2( 1, 0 )
	bodies.add_child( border_left )
	
	# Create top border
	var border_top: BlastBorder = BORDER_SCENE.instantiate()
	border_top.rect = Rect2(
		rect.position.x - BUFFER,
		rect.position.y - BUFFER,
		rect.size.x + BUFFER * 2,
		BUFFER
	)
	border_top.gravity = Vector2( 0, 1 )
	bodies.add_child( border_top )
	
	# Create right borders
	var border_right: BlastBorder = BORDER_SCENE.instantiate()
	border_right.rect = Rect2(
		rect.position.x + rect.size.x,
		rect.position.y - BUFFER,
		BUFFER,
		rect.size.y + BUFFER * 2
	)
	border_right.gravity = Vector2( -1, 0 )
	bodies.add_child( border_right )
	
	# Create bottom border
	var border_bottom: BlastBorder = BORDER_SCENE.instantiate()
	border_bottom.rect = Rect2(
		rect.position.x - BUFFER,
		rect.position.y + rect.size.y,
		rect.size.x + BUFFER * 2,
		BUFFER
	)
	border_bottom.gravity = Vector2( 0, -1 )
	bodies.add_child( border_bottom )
	
	# Create solar stytem
	var planet = PLANET_SCENE.instantiate()
	planet.position = Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2
	)
	bodies.add_child( planet )
	planets.append( planet )
	
	# Create Rocks
	var num_rocks = Blast.get_num_rocks()
	for i in range( num_rocks ):
		var rock: BlastRockBody = ROCK_SCENE.instantiate()
		rock.position = get_random_start_pos()
		rock.linear_velocity = Vector2.from_angle( randf_range( 0, TAU ) ) * 100
		rock.angular_velocity = randf_range( -PI / 2, PI / 2 )
		rock.rock_size = rock_sizes.pick_random()
		bodies.add_child( rock )
		rock.linear_velocity = calc_orbit_velocity( rock, planets[ 0 ].area )
	
	# Create Crates
	var crate_size = 50
	var num_crates = Blast.get_num_crates()
	for i in range( num_crates ):
		var is_big_lot = randf_range( 0, 1 ) > 0.9
		var bonus_crates = 1
		if is_big_lot:
			bonus_crates += clampi( randi_range( -20, 8 ), 1, 8 )
		if bonus_crates == 7:
			bonus_crates = 6
		var cols = [ 0, 1, 2, 3, 2, 5, 3, 4, 4, 3 ][ bonus_crates ]
		var pos = get_random_start_pos( crate_size * cols )
		var x = 0
		var y = 0
		for j in range( bonus_crates ):
			var crate: BlastCrate = CRATE_SCENE.instantiate()
			crate.position = Vector2( pos.x + x * crate_size, pos.y + y * crate_size )
			bodies.add_child( crate )
			crate.linear_velocity = calc_orbit_velocity( crate, planets[ 0 ].area )
			x += 1
			if x >= cols:
				x = 0
				y += 1
	
	# Initialize all bodies
	var player_id: int = 0
	for body in bodies.get_children():
		if body.has_method( "fire_lasers" ):
			var player = Globals.players[ player_id ]
			body.setup_ship( player )
			ships.append( body )
			player_id += 1
		if body.has_method( "init" ):
			body.init( self )


func calc_orbit_velocity( body: RigidBody2D, planet: Area2D ) -> Vector2:
	var speed_multiplier = 1.0
	var distance_to_planet = ( planet.position - body.position ).length()

	# Get the gravity and unit distance from the planet
	var gravity_strength = planet.gravity
	var gravity_point_unit_distance = planet.gravity_point_unit_distance

	# Calculate the effective gravity at the current distance using the inverse square law
	var effective_gravity = gravity_strength * pow( gravity_point_unit_distance / distance_to_planet, 2 )

	# Calculate the orbit speed using v = sqrt(effective_gravity * distance_to_planet)
	var orbit_speed = sqrt( effective_gravity * distance_to_planet ) * speed_multiplier

	# Calculate the direction to orbit (perpendicular to the vector from the planet to the object)
	var direction = ( body.position - planet.position ).normalized()
	
	# Rotate by 90 degrees to get the perpendicular direction for a circular orbit
	return direction.rotated( deg_to_rad( 90 ) ) * orbit_speed


func get_random_start_pos( buffer: float = 0 ) -> Vector2:
	var rect: Rect2 = Blast.get_rect()
	var min_x: float = rect.position.x + buffer
	var min_y: float = rect.position.y + buffer
	var max_x: float = rect.position.x + rect.size.x - buffer * 2
	var max_y: float = rect.position.y + rect.size.y - buffer * 2
	return Vector2(
		randf_range( min_x, max_x ),
		randf_range( min_y, max_y )
	)


func fill_array( item, size ) -> Array:
	var arr = []
	arr.resize( size )
	arr.fill( item )
	return arr


func add_body( body ) -> void:
	bodies.add_child( body )


func create_minimap_material( color: Color ) -> ShaderMaterial:
	var shader_material: ShaderMaterial = ShaderMaterial.new()
	shader_material.shader = MINIMAP_SHADER
	shader_material.set_shader_parameter( "color", color )
	shader_material.set_shader_parameter( "width", 10 )
	shader_material.set_shader_parameter( "pattern", 1 )
	shader_material.set_shader_parameter( "inside", true )
	shader_material.set_shader_parameter( "add_margins", false )
	return shader_material


func create_border_material( color: Color, density: float, gravity: Vector2 ) -> ShaderMaterial:
	var shader_material: ShaderMaterial = ShaderMaterial.new()
	shader_material.shader = BORDER_SHADER
	shader_material.set_shader_parameter( "color", color )
	shader_material.set_shader_parameter( "density", density )
	if gravity.x == 1:
		shader_material.set_shader_parameter( "flip_direction", true )
		shader_material.set_shader_parameter( "rotate_90", true )
	elif gravity.x == -1:
		shader_material.set_shader_parameter( "flip_direction", false )
		shader_material.set_shader_parameter( "rotate_90", true )
	elif gravity.y == 1:
		shader_material.set_shader_parameter( "flip_direction", true )
		shader_material.set_shader_parameter( "rotate_90", false )
	else:
		shader_material.set_shader_parameter( "flip_direction", false )
		shader_material.set_shader_parameter( "rotate_90", false )
	return shader_material


func create_explosions( num: int, radius: float, body: RigidBody2D, esize: float ) -> void:
	for j in range( num, 0, -1 ):
		for i in range( worlds.size() ):
			var world = worlds[ i ]
			var explosion = EXPLOSION_SCENE.instantiate()
			explosion.position = body.position + Vector2(
				randf_range( -radius / 2, radius / 2 ),
				randf_range( -radius / 2, radius / 2 )
			)
			explosion.velocity = body.linear_velocity
			var distance = maxf( explosion.position.distance_to( body.position ), 1.0 )
			var xscale = clampf( ( radius / distance ) * 0.25, 0, 1.0 ) * esize
			explosion.scale = Vector2( xscale, xscale )
			world.add_child( explosion )
		await get_tree().create_timer( randf_range( 0, 0.1 ) ).timeout


func create_pickups(
	pos: Vector2,
	vel: Vector2,
	count: int,
	b_push: float,
	b_move: float
) -> void:
	var da = TAU / count
	var a = TAU * randf_range( 0, 1 )
	var pickup
	var push
	var move
	for i in range( count ):
		pickup = PICKUP_SCENE.instantiate()
		push = Vector2.from_angle( randf_range( a, a + da / 2 ) ) * b_push
		move = Vector2.from_angle( randf_range( a, a + da / 2  ) ) * b_move
		pickup.velocity = vel + push * randf_range( 0.5, 1.0 )
		pickup.position = pos + move
		add_body( pickup )
		pickup.init( self )
		a += da


func create_weapon_pickup(
	pos: Vector2,
	vel: Vector2,
	count: int,
	b_push: float,
	b_move: float,
	weapon: WEAPONS
) -> void:
	var da = TAU / count
	var a = TAU * randf_range( 0, 1 )
	var pickup
	var push
	var move
	for i in range( count ):
		pickup = PICKUP_SCENE.instantiate()
		push = Vector2.from_angle( randf_range( a, a + da / 2 ) ) * b_push
		move = Vector2.from_angle( randf_range( a, a + da / 2  ) ) * b_move
		pickup.velocity = vel + push * randf_range( 0.5, 1.0 )
		pickup.position = pos + move
		pickup.is_energy = false
		pickup.weapon = weapon
		add_body( pickup )
		pickup.init( self )
		a += da


func set_game_over() -> void:
	var game_over_count = 0
	for ship in ships:
		if ship.is_game_over:
			game_over_count += 1
	
	if game_over_count == ships.size() - 1:
		for ship in ships:
			ship.set_physics_process( false )
			ship.disable()
		$CanvasLayer/GameOver.start( self )


func _ready() -> void:
	PhysicsServer2D.area_set_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		Vector2.ZERO
	)
	worlds = []
	uis = []
	for child in $Players/PL/HB.get_children():
		if child is SubViewportContainer:
			worlds.append( child.get_node( "SubViewport/World" ) )
			uis.append( child.get_node( "SubViewport/CanvasLayer/PlayerUI" ) )
			minimaps.append(
				child.get_node(
					"SubViewport/CanvasLayer/PlayerUI/Panel/MiniMap/SubViewport/World"
				)
			)
	init()


func _physics_process( _delta: float ) -> void:
	if Input.is_action_just_pressed( "Exit" ):
		get_tree().change_scene_to_packed( Blast.scenes.menu )
