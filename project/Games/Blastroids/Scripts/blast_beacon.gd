extends Sprite2D
class_name BlastBeacon


var game: BlastGame
var clones: Array = []
var minimap_clones: Array = []
var is_clone: bool = false
var is_active: bool = false


func init( new_game: BlastGame ) -> void:
	game = new_game
	if is_clone:
		$GPUParticles2D.emitting = true
	else:
		game.add_beacon( self )
		init_clones()


func init_clones() -> void:
	
	# Init Clones
	for i in range( game.worlds.size() ):
		var world = game.worlds[ i ]
		var clone: BlastBeacon = BlastGame.BEACON_SCENE.instantiate()
		clone.is_clone = true
		clone.scale = scale
		clone.modulate = modulate
		clone.texture = texture
		clone.position = position
		clones.append( clone )
		world.add_child( clone )
		clone.init( game )
	
		# Create minimap clone
		var minimap = game.minimaps[ i ]
		var mini_clone: Sprite2D = Sprite2D.new()
		mini_clone.scale = Vector2( 15, 15 )
		mini_clone.texture = texture
		minimap.add_child( mini_clone )
		minimap_clones.append( mini_clone )


func destroy() -> void:
	is_active = false
	game.beacons.erase( self )
	for minimap_clone: Sprite2D in minimap_clones:
		minimap_clone.queue_free()
	var tween = create_tween()
	tween.set_parallel( true )
	for clone: BlastBeacon in clones:
		tween.tween_property( clone, "modulate:a", 0.0, 1.0 )
	await tween.finished
	for clone: BlastBeacon in clones:
		clone.queue_free()
	queue_free()


func _physics_process( _delta: float ) -> void:
	for clone: BlastBeacon in clones:
		clone.position = position
		clone.modulate = modulate
	
	if is_active:
		for clone: Sprite2D in minimap_clones:
			clone.position = position
			clone.modulate = modulate
