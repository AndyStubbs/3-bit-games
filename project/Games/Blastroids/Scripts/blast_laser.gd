extends Area2D
class_name BlastLaser


@export var damage: float = 1.0


var mass: float = 0
var clones: Array = []
var velocity: Vector2
var game: BlastGame
var base_h: float
var spin: float
var ship: BlastShipBody


@onready var sprite: Sprite2D = $Sprite2D


func init( fired_from_ship: BlastShipBody ) -> void:
	ship = fired_from_ship
	game = ship.game
	var collision_shape: CollisionShape2D = $CollisionShape2D
	var circle = collision_shape.shape as CircleShape2D
	circle.radius = sprite.scale.x * 5
	for i in range( game.worlds.size() ):
		var world = game.worlds[ i ]
		var clone: Sprite2D = Sprite2D.new()
		clone.offset = sprite.position
		clone.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		clone.scale = sprite.scale
		clone.modulate = sprite.modulate
		clone.modulate.a = 0
		clone.texture = sprite.texture
		world.add_child( clone )
		clones.append( clone )
	

func fire( new_velocity: Vector2, color: Color, new_damage: float, new_rotation: float ) -> void:
	base_h = color.h
	damage = new_damage
	velocity = new_velocity
	rotation = new_rotation
	sprite.modulate = color
	sprite.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property( sprite, "modulate:a", 1.0, 0.5 )
	tween.tween_property( sprite, "modulate:a", 0.0, 0.5 )
	await tween.finished
	destroy()


func destroy() -> void:
	for clone: Sprite2D in clones:
		clone.queue_free()
	clones = []
	queue_free()


func _physics_process( delta: float ) -> void:
	rotation += spin * delta
	sprite.modulate.h = clampf( base_h + randf_range( -0.03, 0.03 ), base_h - 0.12, base_h + 0.12 )
	position += velocity * delta
	for clone: Sprite2D in clones:
		clone.rotation = rotation
		clone.position = position
		clone.modulate = sprite.modulate


func _on_body_entered( body: Node2D ) -> void:
	if body.has_method( "hit" ):
		body.hit( damage * sprite.modulate.a, ship )
		if mass > 0:
			var r_body = body as RigidBody2D
			var diff = ( body.position - position )
			var normal = diff.normalized()
			r_body.apply_impulse( normal * mass, diff )
	if body.has_method( "get_clones" ):
		for clone in body.get_clones():
			var explosion = BlastGame.EXPLOSION_SCENE.instantiate()
			explosion.modulate.a = sprite.modulate.a
			clone.add_child( explosion )
			explosion.global_position = global_position
	destroy()
