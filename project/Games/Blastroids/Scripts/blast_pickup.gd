extends Area2D


@export var is_energy: bool = true
@export var weapon: String


var energy: float = 400
var velocity: Vector2
var a_velocity: float
var clones: Array
var gravity_bodies: Array
var base_accel: float = 350
var gravity_damp: float = 0.95
var game: BlastGame
var is_picked_up: bool = false
var slide_start: Vector2
var slide_body: Node2D
var lifetime: float = 5.0


@onready var sprite: Sprite2D = $Sprite2D


func init( new_game: BlastGame ) -> void:
	game = new_game
	if is_energy:
		modulate.a = 0.75
	else:
		sprite.texture = BlastGame.WEAPONS_DATA[ weapon ].PICKUP_IMAGE
	init_clones()


func init_clones() -> void:
	for i in range( game.worlds.size() ):
		var world = game.worlds[ i ]
		var clone: Sprite2D = Sprite2D.new()
		clone.modulate = modulate
		clone.texture = sprite.texture
		clone.position = position
		clones.append( clone )
		world.add_child( clone )


func update_clones() -> void:
	for clone in clones:
		clone.rotation = rotation
		clone.position = position 
		clone.modulate = modulate


func slide( weight: float ) -> void:
	position = slide_start.lerp( slide_body.position, weight )
	#Globals.debug_line( position, slide_body.position, Color.RED, 1, clones[ 0 ].get_parent(), 2.0 )


func _physics_process( delta: float ) -> void:
	rotation += a_velocity * delta
	modulate.h += randf_range( -1.5, 1.5 ) * delta
	modulate.v += randf_range( -1.5, 1.5 ) * delta
	if gravity_bodies.size() > 0:
		velocity *= gravity_damp
		for body in gravity_bodies:
			velocity += ( body.position - position ).normalized() * base_accel * delta
	if not is_picked_up:
		position += velocity * delta
	update_clones()
	lifetime -= delta
	if lifetime < 0:
		if not is_energy:
			game.on_pickup_destroyed.emit( weapon )
		lifetime = 5.0
		var tween = create_tween()
		tween.tween_property( self, "modulate:a", 0, 0.5 )
		await tween.finished
		for clone in clones:
			clone.queue_free()
		queue_free()


func _on_body_entered( body: Node2D ) -> void:
	if is_picked_up:
		return
	if is_energy and body.has_method( "pickup" ):
		is_picked_up = true
		body.pickup( energy )
		velocity = Vector2.ZERO
		var tween = create_tween()
		tween.set_parallel( true )
		tween.tween_property( self, "modulate:a", 0.0, 0.5 )
		slide_start = Vector2( position )
		slide_body = body
		tween.tween_method( slide, 0.0, 1.0, 0.5 )
		await tween.finished
	if not is_energy and body.has_method( "pickup_weapon" ):
		is_picked_up = true
		body.pickup_weapon( weapon )
	if is_picked_up:
		for clone in clones:
			clone.queue_free()
		queue_free()


func _on_gravity_area_body_entered( body: Node2D ) -> void:
	if body.has_method( "pickup" ):
		gravity_bodies.append( body )


func _on_gravity_area_body_exited( body: Node2D ) -> void:
	if body.has_method( "pickup" ):
		gravity_bodies.erase( body )
