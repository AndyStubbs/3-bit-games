extends Sprite2D


var game: BlastGame
var clones = []


func init( new_game: BlastGame ) -> void:
	game = new_game
	for i in range( game.worlds.size() ):
		var world = game.worlds[ i ]
		var clone_rock: Sprite2D = Sprite2D.new()
		clone_rock.texture = texture
		world.add_child( clone_rock )
		clones.append( clone_rock )


func _physics_process( _delta: float ) -> void:
	for clone: Sprite2D in clones:
		clone.modulate = modulate
		clone.rotation = rotation
		clone.position = position
