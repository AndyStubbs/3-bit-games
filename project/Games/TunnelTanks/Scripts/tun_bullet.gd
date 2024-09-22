extends Node2D
class_name TUN_Bullet


var speed: float = 3
var velocity: Vector2i
var last_pos: Vector2
var direction: String
var clones: Array = []
var tank: TUN_Tank
var damage: float = 15.0
var is_destroyed: bool = false


@onready var anim: AnimatedSprite2D = $Sprite2D


func _ready() -> void:
	Tun.bullet_count += 1


func _physics_process( _delta: float ) -> void:
	if is_destroyed:
		return
	last_pos = position
	position += velocity * speed
	for clone in clones:
		clone.position = position
	Tun.on_bullet_moved.emit( self )


func fire( pos: Vector2, new_direction: String, parent_tank: TUN_Tank ) -> void:
	tank = parent_tank
	direction = new_direction
	position = pos + Tun.BULLET[ direction ].OFFSET
	anim.offset = Tun.BULLET[ direction ].SPRITE_OFFSET
	velocity = Tun.BULLET[ direction ].VELOCITY
	anim.play( direction )
	Tun.on_bullet_fired.emit( self )


func create_clone() -> AnimatedSprite2D:
	var clone = AnimatedSprite2D.new()
	clone.modulate = modulate
	clone.centered = false
	clone.sprite_frames = anim.sprite_frames
	clone.play( direction )
	clone.offset = anim.offset
	clone.position = position
	clones.append( clone )
	return clone


func destroy() -> void:
	is_destroyed = true
	modulate.a = 0
	
	# Reduce the bullet count
	Tun.bullet_count -= 1
	
	# Destroy the clones
	for clone: AnimatedSprite2D in clones:
		destroy_clone( clone )
	
	queue_free()


func destroy_clone( clone: AnimatedSprite2D ) -> void:
	clone.modulate.a = 0
	clone.queue_free()
