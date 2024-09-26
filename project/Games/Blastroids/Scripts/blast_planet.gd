extends Node2D
class_name BlastPlanet


const DATA: Dictionary = {
	"sun": {
		"image": preload( "res://Games/Blastroids/Images/sun.webp" ),
		"gravity_radius": 5000,
		"point_unit_distance": 2500,
		"atmosphere_radius": 785,
		"inner_radius": 200,
		"color": Color( 0.9, 0.9, 0.0 ),
		"is_burn": true
	},
	"mercury": {
		"image": preload( "res://Games/Blastroids/Images/mercury.webp" ),
		"gravity_radius": 800,
		"point_unit_distance": 400,
		"atmosphere_radius": 200,
		"inner_radius": 95,
		"color": Color( "#8c8c8c" ),
		"is_burn": true
	},
	"venus": {
		"image": preload( "res://Games/Blastroids/Images/venus.webp" ),
		"gravity_radius": 1200,
		"point_unit_distance": 600,
		"atmosphere_radius": 445,
		"inner_radius": 95,
		"color": Color( "#98fe21" ),
		"is_burn": true 
	},
	"earth": {
		"image": preload( "res://Games/Blastroids/Images/earth.webp" ),
		"gravity_radius": 1500,
		"point_unit_distance": 750,
		"atmosphere_radius": 460,
		"inner_radius": 100,
		"color": Color( 0.3, 0.3, 1.0 ),
		"is_burn": true
	},
	"moon": {
		"image": preload( "res://Games/Blastroids/Images/moon_small.webp" ),
		"gravity_radius": 700,
		"point_unit_distance": 350,
		"atmosphere_radius": 155,
		"inner_radius": 40,
		"color": Color( 0.9, 0.9, 0.9 ),
		"is_burn": true
	},
	"mars": {
		"image": preload( "res://Games/Blastroids/Images/mars.webp" ),
		"gravity_radius": 900,
		"point_unit_distance": 450,
		"atmosphere_radius": 385,
		"inner_radius": 60,
		"color": Color( "#a76e4d" ),
		"is_burn": true
	},
}


var clones: Array = []
var minimap_clones: Array = []
var game: BlastGame
var atmosphere_bodies: Array = []
var radius: float = 100
var is_orbiting = false
var orbit_planet: BlastPlanet
var orbit_radius: float
var orbit_angle: float
var orbit_da: float
var gravity_bodies: Array = []
var data: Dictionary
var is_burn: bool = false


@onready var sprite: Sprite2D = $Sprite2D
@onready var gravity_area: Area2D = $GravityArea
@onready var gravity_collision_shape: CollisionShape2D = $GravityArea/CollisionShape2D


func load( planet_type: String ) -> void:
	data = DATA[ planet_type ]
	is_burn = data.is_burn
	$Sprite2D.texture = data.image
	$GravityArea.gravity_point_unit_distance = data.point_unit_distance
	create_new_circle_shape( $GravityArea/CollisionShape2D, data.gravity_radius )
	create_new_circle_shape( $AtmosphereArea/CollisionShape2D, data.atmosphere_radius )
	if is_burn:
		create_new_circle_shape( $StaticBody2D/CollisionShape2D, data.inner_radius )
	else:
		$StaticBody2D.queue_free()
	radius = data.atmosphere_radius


func create_new_circle_shape( collision_shape: CollisionShape2D, r: float ) -> void:
	collision_shape.shape = CircleShape2D.new()
	collision_shape.debug_color = data.color
	collision_shape.shape.radius = r


func setup_orbit( planet: BlastPlanet, r: float ) -> void:
	is_orbiting = true
	orbit_planet = planet
	orbit_radius = r
	#orbit_angle = randf_range( 0, TAU )
	orbit_angle = 0
	orbit_da = TAU * 15 / r
	process_orbit( 0 )


func init( new_game: BlastGame ) -> void:
	game = new_game
	init_clones()


func init_clones() -> void:
	for i in range( game.worlds.size() ):
		var world = game.worlds[ i ]
		var clone: Sprite2D = Sprite2D.new()
		clone.scale = sprite.scale
		clone.modulate = sprite.modulate
		clone.texture = sprite.texture
		clone.position = position
		clones.append( clone )
		world.add_child( clone )
		
		# Create minimap clone
		var minimap = game.minimaps[ i ]
		var mini_clone: Sprite2D = Sprite2D.new()
		mini_clone.scale = sprite.scale
		mini_clone.texture = sprite.texture
		mini_clone.material = game.create_minimap_material( data.color )
		minimap.add_child( mini_clone )
		minimap_clones.append( mini_clone )


func process_orbit( delta: float ) -> void:
	var new_position = orbit_planet.position + Vector2(
		cos( orbit_angle ) * orbit_radius,
		sin( orbit_angle ) * orbit_radius,
	)
	orbit_angle += orbit_da * delta
	position = new_position


func update_clones() -> void:
	for clone in clones:
		clone.rotation = rotation
		clone.position = position 
		clone.modulate = modulate
	for clone in minimap_clones:
		clone.rotation = rotation
		clone.position = position


func _physics_process( delta: float ) -> void:
	if is_orbiting:
		process_orbit( delta )
	if is_burn:
		for body in atmosphere_bodies:
			var distance = abs( radius - position.distance_to( body.position ) )
			var damage = distance * distance * delta * 0.15
			body.burn( damage )
	update_clones()


func _on_atmosphere_area_body_entered( body: Node2D ) -> void:
	if body.has_method( "burn" ):
		atmosphere_bodies.append( body )


func _on_atmosphere_area_body_exited( body: Node2D ) -> void:
	if body.has_method( "burn" ):
		atmosphere_bodies.erase( body )


func _on_gravity_area_body_entered( body: Node2D ) -> void:
	if body is RigidBody2D:
		gravity_bodies.append( body )


func _on_gravity_area_body_exited( body: Node2D ) -> void:
	if body is RigidBody2D:
		gravity_bodies.erase( body )
