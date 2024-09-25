extends Node2D
class_name BlastPlanet


const DATA: Dictionary = {
	"sun": {
		"image": preload( "res://Games/Blastroids/Images/sun.webp" ),
		"gravity_radius": 5000,
		"atmosphere_radius": 1000,
		"inner_radius": 200,
		"color": Color( 0.9, 0.9, 0.0 ) 
	},
	"mercury": {
		"image": preload( "res://Games/Blastroids/Images/mercury.webp" ),
		"gravity_radius": 800,
		"atmosphere_radius": 200,
		"inner_radius": 95,
		"color": Color( "#8c8c8c" )
	},
	"venus": {
		"image": preload( "res://Games/Blastroids/Images/venus.webp" ),
		"gravity_radius": 1200,
		"atmosphere_radius": 445,
		"inner_radius": 95,
		"color": Color( "#bf7c21" ) 
	},
	"earth": {
		"image": preload( "res://Games/Blastroids/Images/earth.webp" ),
		"gravity_radius": 1500,
		"atmosphere_radius": 460,
		"inner_radius": 100,
		"color": Color( 0.3, 0.3, 1.0 ) 
	},
	"moon": {
		"image": preload( "res://Games/Blastroids/Images/moon_small.webp" ),
		"gravity_radius": 700,
		"atmosphere_radius": 155,
		"inner_radius": 40,
		"color": Color( 0.9, 0.9, 0.9 )
	},
	"mars": {
		"image": preload( "res://Games/Blastroids/Images/mars.webp" ),
		"gravity_radius": 900,
		"atmosphere_radius": 385,
		"inner_radius": 60,
		"color": Color( "#a76e4d" )
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


@onready var sprite = $Sprite2D
@onready var gravity_area = $GravityArea
@onready var gravity_collision_shape = $GravityArea/CollisionShape2D


func load( planet_type: String ) -> void:
	data = DATA[ planet_type ]
	$Sprite2D.texture = data.image
	create_new_circle_shape( $GravityArea/CollisionShape2D, data.gravity_radius )
	create_new_circle_shape( $AtmosphereArea/CollisionShape2D, data.atmosphere_radius )
	create_new_circle_shape( $StaticBody2D/CollisionShape2D, data.inner_radius )
	radius = data.atmosphere_radius


func create_new_circle_shape( collision_shape: CollisionShape2D, r: float ) -> void:
	collision_shape.shape = CircleShape2D.new()
	collision_shape.debug_color = data.color
	collision_shape.shape.radius = r


func setup_orbit( planet: BlastPlanet, r: float ) -> void:
	is_orbiting = true
	orbit_planet = planet
	orbit_radius = r
	orbit_angle = randf_range( 0, TAU )
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
		clone.modulate = modulate
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
