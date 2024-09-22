extends Sprite2D
class_name BlinkingIcon


var d: float = 1.0
var speed: float = 3.0


func _physics_process( delta: float ) -> void:
	modulate.a = clampf( modulate.a + d * speed * delta, 0, 1.0 )
	if modulate.a == 0 or modulate.a == 1.0:
		d *= -1
