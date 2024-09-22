extends AnimatedSprite2D


var velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	modulate.h += randf_range( -0.05, 0.05 )
	modulate.v += randf_range( -0.05, 0.05 )
	rotation = randf_range( 0, TAU )
	sprite_frames.set_animation_speed( "default", randf_range( 20, 40 ) )
	await animation_finished
	var tween = create_tween()
	tween.tween_property( self, "modulate:a", 0.0, 0.5 )
	await tween.finished
	queue_free()


func _physics_process( delta: float) -> void:
	position += velocity * delta
