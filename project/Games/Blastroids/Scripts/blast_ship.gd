extends Node2D
class_name BlastShip


const STAR_DENSITY = 6553


@export var is_main_ship: bool = false
@export var ship_body: BlastShipBody


var camera_pos: Vector2
var rockets: Array = []
var enemies: Array = []


@onready var stars = $Stars
@onready var stars2 = $Stars2
@onready var stars3 = $Stars3
@onready var stars4 = $Stars4
@onready var stars5 = $Stars5
@onready var camera: Camera2D = $Camera2D
@onready var vector: Node2D = $Vector
@onready var vector_sprite: Sprite2D = $Vector/VectorSprite
@onready var sprite: Sprite2D = $Sprite2D
@onready var sprite_markers: Sprite2D = $Sprite2D/Sprite2D
@onready var ship_vectors: Node2D = $Vector/Ships
@onready var gun_charges: Node2D = $Sprite2D/GunCharges
@onready var low_energy_sprite: Sprite2D = $LowEnergySprite


func init_stars( star_scene: PackedScene ) -> void:
	var size = get_viewport_rect().size
	var star_count = roundi( ( size.x * size.y ) / STAR_DENSITY )
	for i in range( star_count ):
		var star = star_scene.instantiate()
		star.ship_body = ship_body
		star.init()
		if star.scale.x < 0.8:
			stars.add_child( star )
		elif star.scale.x < 1.1:
			stars2.add_child( star )
		elif star.scale.x < 1.4:
			stars3.add_child( star )
		elif star.scale.x < 1.7:
			stars4.add_child( star )
		else:
			stars5.add_child( star )


func init_main_ship() -> void:
	var buffer: int = 500
	var rect: Rect2 = Blast.get_rect()
	camera.limit_left = roundi( rect.position.x ) - buffer
	camera.limit_right = roundi( rect.position.x + rect.size.x ) + buffer
	camera.limit_top = roundi( rect.position.y ) - buffer
	camera.limit_bottom = roundi( rect.position.y + rect.size.y ) + buffer
	var star_scene = load( "res://Games/Blastroids/Scenes/blast_star.tscn" )
	init_stars( star_scene )
	vector_sprite.modulate = ship_body.ui_color
	vector_sprite.modulate.a = 0.75
	
	# Wait one frame for all ships to be added
	await get_tree().physics_frame
	for ship in ship_body.game.ships:
		if ship != ship_body:
			var ship_vector = Sprite2D.new()
			var ship_vector_front = Sprite2D.new()
			ship_vector_front.position.x = -0.5
			ship_vector_front.scale = Vector2( 0.75, 0.75 )
			ship_vector_front.texture = ship_body.game.TRI_IMAGE
			ship_vector_front.modulate = ship.ui_color
			ship_vector.add_child( ship_vector_front )
			ship_vector.texture = ship_body.game.TRI_IMAGE
			#ship_vector.modulate.h += 0.15
			ship_vector.self_modulate.a = 0
			ship_vectors.add_child( ship_vector )
			enemies.append( ship )


func update( delta: float ) -> void:
	position = ship_body.position
	sprite.rotation = ship_body.rotation
	if ship_body.start_thrusting:
		for rocket: GPUParticles2D in rockets:
			if rocket and not rocket.emitting:
				rocket.emitting = true
	if ship_body.stop_thrusting:
		for rocket: GPUParticles2D in rockets:
			if rocket and rocket.emitting:
				rocket.emitting = false
	if ship_body.blast_charge_size == 0:
		gun_charges.hide()
	else:
		gun_charges.show()
		for child in gun_charges.get_children():
			child.scale = Vector2( ship_body.blast_charge_size, ship_body.blast_charge_size )
			child.position.x = 28 + ship_body.blast_charge_size * 10
	if is_main_ship:
		update_main_ship( delta )


func update_main_ship( delta: float ) -> void:
	stars.position = position * -0.35
	stars2.position = position * -0.45
	stars3.position = position * -0.55
	stars4.position = position * -0.65
	stars5.position = position * -0.75
	
	# Update camera position
	var pos: Vector2
	if ship_body.speed < 100:
		vector_sprite.modulate.a = 0
	else:
		vector_sprite.modulate.a = 0.85
		pos = ship_body.linear_velocity.normalized() * 75
	
	for i in range( enemies.size() ):
		var ship: BlastShipBody = enemies[ i ]
		var ship_vector = ship_vectors.get_child( i )
		var ship_diff = ( ship.position - position )
		var ship_vector_pos = ship_diff.normalized() * 75
		var a = 1.0 - ship_diff.length_squared() * 0.0000001
		ship_vector.position = ship_vector_pos
		ship_vector.rotation = ship_vector_pos.angle()
		ship_vector.modulate.a = clampf( a, 0.6, 1.0 )
		ship_vector.scale = Vector2( ship_vector.modulate.a, ship_vector.modulate.a )
		if a > 0.94:
			ship_vector.self_modulate.a = 1
		else:
			ship_vector.self_modulate.a = 0
		if ship.is_game_over:
			ship_vector.hide()
	#if ship_body.speed < 15625:
		#pos = ship_body.linear_velocity
	#else:
		#pos = ship_body.linear_velocity.normalized() * 50
	vector_sprite.position = pos
	vector_sprite.rotation = ship_body.linear_velocity.angle()
	camera_pos = pos
	camera.position = camera.position.lerp( camera_pos, 0.5 * delta )
	
	if ship_body.energy < ship_body.min_energy * 2.0:
		low_energy_sprite.modulate.a = minf( low_energy_sprite.modulate.a + delta, 1.0 )
	else:
		low_energy_sprite.modulate.a = maxf( low_energy_sprite.modulate.a - delta, 0.0 )
	
	# Show stats
	#$Label.text = "%d / %d / %d" % [ ship_body.shields, ship_body.health, ship_body.energy ]
	#$Label.text = "%d" % ship_body.speed
	#$Label.text = "%d" % sqrt( ship_body.speed )
	$Label.text = "%d" % rad_to_deg( ship_body.rotation_speed )
	#$Label.text = "%d" % rad_to_deg( Globals.normalize_angle( ship_body.rotation ) )
	#$Label.text = "%d - %d" % [
		#rad_to_deg( Globals.normalize_angle( ship_body.rotation ) ),
		#rad_to_deg( Globals.normalize_angle( ship_body.linear_velocity.angle() ) )
	#]


func raise_shields() -> void:
	$ShieldsParticles.emitting = true


func _ready() -> void:
	rockets = [
		$Sprite2D/Rockets/Rocket/RocketParticles,
		$Sprite2D/Rockets/Rocket/RocketParticles2,
		$Sprite2D/Rockets/Rocket2/RocketParticles,
		$Sprite2D/Rockets/Rocket2/RocketParticles2
	]
	sprite_markers.modulate = ship_body.ui_color
	gun_charges.modulate = ship_body.ui_color
	if is_main_ship:
		init_main_ship()
	else:
		$Vector.queue_free()
		stars.queue_free()
		stars2.queue_free()
		stars3.queue_free()
		stars4.queue_free()
		stars5.queue_free()
		camera.queue_free()
