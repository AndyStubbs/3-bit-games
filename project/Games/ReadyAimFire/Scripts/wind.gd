extends Sprite2D


var level: RAF_Level
var velocity: Vector2 = Vector2( 0, 180.0 )


func init( new_level: RAF_Level ) -> void:
	level = new_level


func _physics_process( delta: float ) -> void:
	velocity.x = level.wind.x
	position += velocity * delta
	if roundi( position.y / level.scale ) > level.height:
		queue_free()
