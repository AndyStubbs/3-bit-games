extends Node2D
class_name BlastPlanet


var clones: Array = []
var minimap_clones: Array = []
var game: BlastGame
var atmosphere_bodies: Array = []
var radius: float = 100


@onready var sprite = $Sprite2D
@onready var area = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D


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
		mini_clone.material = game.create_minimap_material( Color( 0.3, 0.3, 1.0 ) )
		minimap.add_child( mini_clone )
		minimap_clones.append( mini_clone )


func _ready() -> void:
	radius = $AtmosphereArea/CollisionShape2D.shape.radius
	radius = radius


func _physics_process( delta: float ) -> void:
	for body in atmosphere_bodies:
		var distance = abs( radius - position.distance_to( body.position ) )
		var damage = distance * distance * delta * 0.15
		body.burn( damage )


func _on_atmosphere_area_body_entered( body: Node2D ) -> void:
	if body.has_method( "burn" ):
		atmosphere_bodies.append( body )


func _on_atmosphere_area_body_exited( body: Node2D ) -> void:
	if body.has_method( "burn" ):
		atmosphere_bodies.erase( body )
