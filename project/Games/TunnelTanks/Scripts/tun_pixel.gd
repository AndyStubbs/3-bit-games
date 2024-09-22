extends Sprite2D
class_name TUN_Pixel


var angle: float = 0
var speed: float = 12.0
var min_speed: float = 1.0
var max_speed: float = 12.0
var min_duration: float = 0.1
var max_duration: float = 0.2
var pos: Vector2
var clones: Array = []


func _ready() -> void:
	pos = position
	angle = randf_range( 0, TAU )
	speed = randf_range( min_speed, max_speed )
	modulate.a = 1
	
	var tween = create_tween()
	tween.tween_property( self, "modulate:a", 1.0, randf_range( min_duration, max_duration ) )
	tween.tween_property( self, "modulate:a", 0.0, randf_range( min_duration, max_duration ) )
	await tween.finished
	
	destroy()
	queue_free()


func create_clone() -> Sprite2D:
	var clone = Sprite2D.new()
	clone.centered = false
	clone.texture = texture
	clone.position = pos
	clone.modulate = modulate	
	clones.append( clone )
	
	return clone


func _physics_process( delta: float ) -> void:
	pos.x += cos( angle ) * speed * delta
	pos.y += sin( angle ) * speed * delta
	position.x = roundf( pos.x )
	position.y = roundf( pos.y )
	for clone in clones:
		clone.position = position
		clone.modulate.a = modulate.a
	Tun.on_pixel_moved.emit( self )


func destroy() -> void:
	modulate.a = 0
	for clone in clones:
		clone.modulate.a = 0
		clone.queue_free()
	
	clones = []
	
	set_physics_process( false )
