extends Node
class_name BlastGame


enum WEAPONS {
	LASER, MASS, MISSILE, SPREAD, CHARGE, BOMB
}


const BEACON_SCENE = preload( "res://Games/Blastroids/Scenes/blast_beacon.tscn" )
const TUTORIAL_SCENE = preload( "res://Games/Blastroids/Scenes/blast_tutorial.tscn" )
const SHIP_BODY = preload( "res://Games/Blastroids/Scenes/blast_ship_body.tscn" )
const PL_ONE = preload( "res://Games/Blastroids/Scenes/pl_one.tscn" )
const PL_TWO = preload( "res://Games/Blastroids/Scenes/pl_two.tscn" )
const PL_THREE = preload( "res://Games/Blastroids/Scenes/pl_three.tscn" )
const PL_FOUR = preload( "res://Games/Blastroids/Scenes/pl_four.tscn" )
const PLAYER_UI_SMALL = preload( "res://Games/Blastroids/Images/blast_player_ui_small.png" )
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
const ROCK_SCENE_BODY = preload( "res://Games/Blastroids/Scenes/blast_rock_body.tscn" )
const ROCK_SCENE = preload( "res://Games/Blastroids/Scenes/blast_rock.tscn" )
const CRATE_BODY_SCENE = preload( "res://Games/Blastroids/Scenes/blast_crate_body.tscn" )
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
var beacons: Array = []
var minimaps: Array = []
var ui_items: Array = []
var planets: Array = []
var rigid_bodies: Array = []
var init_time: float


@onready var bodies = $CanvasLayer/SubViewportContainer/WorldViewport/World/Bodies


func init() -> void:
	var pl = $Players/PL
	ui_items.append_array( pl.get_ui_items() )
	init_containers()
	init_borders()
	init_map()
	init_rocks()
	init_crates()
	
	# Initialize all bodies
	for body in bodies.get_children():
		if body.has_method( "fire_lasers" ):
			ships.append( body )
			rigid_bodies.append( body )
		if body.has_method( "init" ):
			body.init( self )


func init_containers() -> void:
	var base_size: Vector2 = Vector2( 355.6, 200.0 )
	var map_scale: float = 0.1
	if Blast.data.settings.map_size == 0:
		map_scale = 0.1
	elif Blast.data.settings.map_size == 1:
		map_scale = 0.09
	elif Blast.data.settings.map_size == 2:
		map_scale = 0.08
	elif Blast.data.settings.map_size == 3:
		map_scale = 0.07
	elif Blast.data.settings.map_size == 4:
		if Blast.data.settings.map_type == 2:
			map_scale = 0.05
		elif Blast.data.settings.map_type == 1:
			map_scale = 0.055
		else:
			map_scale = 0.06
	
	var rect: Rect2 = Blast.get_rect()
	var grid_size = minf( rect.size.x / 10, rect.size.y / 10 )
	for minimap: Node2D in minimaps:
		var subviewport: SubViewport = minimap.get_parent()
		var subviewport_container: SubViewportContainer = subviewport.get_parent()
		subviewport.size = base_size / map_scale
		subviewport_container.size = base_size / map_scale
		subviewport_container.scale = Vector2( map_scale, map_scale )
		
		# Create grid
		
		# Vertical lines
		var y = rect.position.y
		for x2 in range( grid_size, rect.size.x / 2, grid_size ):
			for i in range( 2 ):
				var flip: float = 1
				if i == 1:
					flip = -1
				var line = Line2D.new()
				line.add_point( Vector2( x2 * flip, y ) )
				line.add_point( Vector2( x2 * flip, rect.size.y / 2 ) )
				line.modulate = Color( 0.1, 0.1, 0.75, 0.75 )
				line.width = 3 / map_scale
				minimap.add_child( line )
		
		# Horizontal Lines
		var x = rect.position.x
		for y2 in range( grid_size, rect.size.y, grid_size ):
			for i in range( 2 ):
				var flip: float = 1
				if i == 1:
					flip = -1
				var line = Line2D.new()
				line.add_point( Vector2( x, y2 * flip ) )
				line.add_point( Vector2( x + rect.size.x, y2 * flip ) )
				line.modulate = Color( 0.1, 0.1, 0.75, 0.75 )
				line.width = 3 / map_scale
				minimap.add_child( line )
		
		# Draw vertical bold lines
		var xs: Array = [ -rect.size.x / 2, 0, rect.size.x / 2 ]
		for i in range( xs.size() ):
			var line3 = Line2D.new()
			line3.add_point( Vector2( xs[ i ], y ) )
			line3.add_point( Vector2( xs[ i ], rect.size.y / 2 ) )
			line3.modulate = Color( 0.2, 0.2, 0.9, 1 )
			line3.width = 3 / map_scale
			minimap.add_child( line3 )
		
		# Draw horizontal bold line
		var ys: Array = [ -rect.size.y / 2, 0, rect.size.y / 2 ]
		for i in range( 3 ):
			var line4 = Line2D.new()
			line4.add_point( Vector2( x, ys[ i ] ) )
			line4.add_point( Vector2( x + rect.size.x, ys[ i ] ) )
			line4.modulate = Color( 0.2, 0.2, 0.9, 1 )
			line4.width = 3 / map_scale
			minimap.add_child( line4 )


func init_borders() -> void:
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


func init_map() -> void:
	var rect: Rect2 = Blast.get_rect()
	
	var radius = rect.size.x / 2
	if rect.size.y < rect.size.x:
		radius = rect.size.y / 2
	
	# Earth System
	if Blast.data.settings.map_type == 1:
		var planet = PLANET_SCENE.instantiate()
		planet.load( "sun" )
		planet.position = Vector2(
			rect.position.x + rect.size.x / 2,
			rect.position.y + rect.size.y / 2
		)
		bodies.add_child( planet )
		planet.gravity_collision_shape.shape.radius = radius
		planets.append( planet )
	
	# Inner solar system
	elif Blast.data.settings.map_type == 2:
		
		# The Sun
		var sun = PLANET_SCENE.instantiate()
		sun.load( "sun" )
		sun.position = Vector2(
			rect.position.x + rect.size.x / 2,
			rect.position.y + rect.size.y / 2
		)
		bodies.add_child( sun )
		sun.gravity_collision_shape.shape.radius = radius
		planets.append( sun )
		
		# Mercury
		var mercury = PLANET_SCENE.instantiate()
		mercury.load( "mercury" )
		bodies.add_child( mercury )
		planets.append( mercury )
		mercury.setup_orbit( sun, 2500 )
		
		# Venus
		var venus = PLANET_SCENE.instantiate()
		venus.load( "venus" )
		bodies.add_child( venus )
		planets.append( venus )
		venus.setup_orbit( sun, 3500 )
		
		# Earth
		var earth = PLANET_SCENE.instantiate()
		earth.load( "earth" )
		bodies.add_child( earth )
		planets.append( earth )
		earth.setup_orbit( sun, 5500 )
		
		# The Moon
		var moon = PLANET_SCENE.instantiate()
		moon.load( "moon" )
		bodies.add_child( moon )
		planets.append( moon )
		moon.setup_orbit( earth, 1000 )
		
		# Mars
		var mars = PLANET_SCENE.instantiate()
		mars.load( "mars" )
		bodies.add_child( mars )
		planets.append( mars )
		mars.setup_orbit( sun, 7500 )


func init_rocks() -> void:
	var rock_sizes: Array = []
	rock_sizes.append_array( fill_array( "huge", 5 ) )
	rock_sizes.append_array( fill_array( "large", 4 ) )
	rock_sizes.append_array( fill_array( "medium", 3 ) )
	rock_sizes.append_array( fill_array( "small", 3 ) )
	rock_sizes.append_array( fill_array( "tiny", 3 ) )
	
	# Create Rocks
	var num_rocks = Blast.get_num_rocks()
	if Blast.data.settings.map_type == 1:
		num_rocks = roundi( num_rocks * 0.5 )
	for i in range( num_rocks ):
		var rock: BlastRockBody = ROCK_SCENE_BODY.instantiate()
		rock.rock_size = rock_sizes.pick_random()
		rock.set_collision_mask_value( 1, false )
		bodies.add_child( rock )
		rigid_bodies.append( rock )
		var is_placed: bool = false
		while not is_placed:
			rock.position = get_random_start_pos( 0, true )
			rock.shape_cast.force_shapecast_update()
			is_placed = not rock.shape_cast.is_colliding()
		if Blast.data.settings.map_type == 0:
			rock.linear_velocity = Vector2.from_angle( randf_range( 0, TAU ) ) * 100
		rock.angular_velocity = randf_range( -PI / 2, PI / 2 )


func init_crates() -> void:
	
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
			var crate: BlastCrateBody = CRATE_BODY_SCENE.instantiate()
			crate.position = Vector2( pos.x + x * crate_size, pos.y + y * crate_size )
			bodies.add_child( crate )
			rigid_bodies.append( crate )
			x += 1
			if x >= cols:
				x = 0
				y += 1


func get_orbit_velocity( body: RigidBody2D ) -> Vector2:
	return calc_orbit_velocity_from_planet( body, planets[ 0 ] )


func calc_orbit_velocity_from_planet( body: RigidBody2D, planet: BlastPlanet ) -> Vector2:
	var area = planet.gravity_area
	var speed_multiplier = 1.0
	var distance_to_planet = ( planet.position - body.position ).length()

	# Get the gravity and unit distance from the planet
	var gravity_strength = area.gravity
	var gravity_point_unit_distance = area.gravity_point_unit_distance

	# Calculate the effective gravity at the current distance using the inverse square law
	var effective_gravity = gravity_strength * pow(
		gravity_point_unit_distance / distance_to_planet,
		2
	)

	# Calculate the orbit speed using v = sqrt(effective_gravity * distance_to_planet)
	var orbit_speed = sqrt( effective_gravity * distance_to_planet ) * speed_multiplier

	# Calculate the direction to orbit (perpendicular to the vector from the planet to the object)
	var direction = ( body.position - planet.position ).normalized()
	
	# Rotate by 90 degrees to get the perpendicular direction for a circular orbit
	return direction.rotated( deg_to_rad( 90 ) ) * orbit_speed


func get_random_start_pos( buffer: float = 0, is_rock: bool = false ) -> Vector2:
	var rect: Rect2 = Blast.get_rect()
	var min_x: float = rect.position.x + buffer
	var min_y: float = rect.position.y + buffer
	var max_x: float = rect.position.x + rect.size.x - buffer * 2
	var max_y: float = rect.position.y + rect.size.y - buffer * 2
	var pos: Vector2
	if Blast.data.settings.map_type == 0:
		pos = Vector2(
			randf_range( min_x, max_x ),
			randf_range( min_y, max_y )
		)
	else:
		var sun = planets[ 0 ]
		var min_radius = sun.radius + 500
		var max_radius = sun.gravity_collision_shape.shape.radius * 0.95
		if is_rock and Blast.data.settings.map_type == 2:
			min_radius = 8500
		var is_placed: bool = false
		var safe_distance: float = 1000 * 1000
		while not is_placed:
			var a = randf_range( 0, TAU )
			var r = randf_range( min_radius, max_radius )
			pos = Vector2( cos( a ) * r, sin( a ) * r )
			is_placed = true
			for planet in planets:
				var distance = pos.distance_squared_to( planet.position )
				if distance < safe_distance:
					is_placed = false
	return pos


func fill_array( item, size ) -> Array:
	var arr = []
	arr.resize( size )
	arr.fill( item )
	return arr


func add_body( body ) -> void:
	bodies.add_child( body )


func add_beacon( beacon: BlastBeacon ) -> void:
	beacons.append( beacon )


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


func setup_players() -> void:
	var players: Array = []
	if Blast.data.is_tutorial:
		var player = {
			"id": 0,
			"enabled": true,
			"name": "TR_PLAYER_1",
			"controls": "ANY",
			"colors": 0,
			"image_id": 0,
			"name_changed": false
		}
		players.append( player )
	else:
		for player in Globals.players:
			if player.enabled:
				players.append( player )
	var pl: Panel
	if players.size() == 1:
		pl = PL_ONE.instantiate()
		Blast.data.player_count = 1
	elif players.size() == 2:
		pl = PL_TWO.instantiate()
		Blast.data.player_count = 2
	elif players.size() == 3:
		pl = PL_THREE.instantiate()
		Blast.data.player_count = 3
	else:
		pl = PL_FOUR.instantiate()
		Blast.data.player_count = 4
	$Players.add_child( pl )
	var bodies2 = $CanvasLayer/SubViewportContainer/WorldViewport/World/Bodies
	var world_id = 0
	for player in players:
		var ship_body = SHIP_BODY.instantiate()
		ship_body.world_id = world_id
		bodies2.add_child( ship_body )
		ship_body.setup_ship( player )
		world_id += 1
	for i in Blast.data.settings.added_cpus:
		var ship_body = SHIP_BODY.instantiate()
		ship_body.world_id = -1
		bodies2.add_child( ship_body )
		ship_body.setup_ship( {
			"colors": null,
			"name": "CPU " + str( i + 1 ),
			"controls": "CPU",
			"image_id": null,
			"name_changed": false
		} )


func _ready() -> void:
	if not Blast.data.settings:
		Blast.data.settings = Blast.settings
	var tutorial
	if Blast.data.is_tutorial:
		tutorial = TUTORIAL_SCENE.instantiate()
		$CanvasLayer.add_child( tutorial )
		tutorial.init( self )
		Blast.data.settings = tutorial.get_settings()
	Globals.is_menu_page = false
	setup_players()
	PhysicsServer2D.area_set_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		Vector2.ZERO
	)
	worlds = []
	uis = []
	for child in $Players/PL.get_containers():
		if child is SubViewportContainer:
			worlds.append( child.get_node( "SubViewport/World" ) )
			uis.append( child.get_node( "SubViewport/CanvasLayer/PlayerUI" ) )
			minimaps.append(
				child.get_node(
					"SubViewport/CanvasLayer/PlayerUI/Panel/MiniMap/SubViewport/World"
				)
			)
	init()
	init_time = Time.get_ticks_msec() + 1000
	if tutorial:
		tutorial.start()


func _physics_process( _delta: float ) -> void:
	if Input.is_action_just_pressed( "Exit" ):
		get_tree().change_scene_to_packed( Blast.scenes.menu )
	if Blast.data.settings.map_type > 0 and Time.get_ticks_msec() < init_time:
		for body: RigidBody2D in rigid_bodies:
			body.linear_velocity = get_orbit_velocity( body )
