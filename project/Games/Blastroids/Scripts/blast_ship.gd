extends Node2D
class_name BlastShip


const CROSSHAIR_GREEN = Color( 0, 1, 0, 1 )
const CROSSHAIR_WHITE = Color( 1, 1, 1, 0.75 )
const LOW_ENERGY_WARN_PCT = 0.33
const LOW_ENERGY_WARN_PCT2 = 0.15
const STAR_DENSITY = 6553
const ZOOM_DX = 0.075
const ZOOM_SIZE = 0.3


@export var is_main_ship: bool = false
@export var ship_body: BlastShipBody


var camera_pos: Vector2
var rockets: Array = []
var enemies: Array = []
var laser_sounds: Array
var shield_hit_sounds: Array
var body_hit_sounds: Array
var pickup_sounds: Array
var health_bar_tween: Tween
var crosshair_tween: Tween
var is_crosshair_green: bool = false
var blink_d: float = 1.0
var target_beacon: BlastBeacon


@onready var stars = $Stars
@onready var stars2 = $Stars2
@onready var stars3 = $Stars3
@onready var stars4 = $Stars4
@onready var stars5 = $Stars5
@onready var camera: Camera2D = $Camera2D
#@onready var vector: Node2D = $Vector
@onready var vector_sprite: Sprite2D = $Vector/VectorSprite
@onready var sprite: Sprite2D = $Sprite2D
@onready var sprite_markers: Sprite2D = $Sprite2D/Sprite2D
@onready var ship_vectors: Node2D = $Vector/Ships
@onready var gun_charges: Node2D = $Sprite2D/GunCharges
@onready var shield_particles: GPUParticles2D = $ShieldsParticles
@onready var low_energy_sprite: Sprite2D = $LowEnergySprite
@onready var burn_particles: GPUParticles2D = $BurnParticles
@onready var health_bar_panel: Panel = $HealthBarPanel
@onready var health_bar: ProgressBar = $HealthBarPanel/HealthBar
@onready var start_sound: AudioStreamPlayer2D = $Sounds/StartSound
@onready var thrust_sound: AudioStreamPlayer2D = $Sounds/ThrustSound
@onready var laser_sound: AudioStreamPlayer2D = $Sounds/LaserSound
@onready var laser_sound2: AudioStreamPlayer2D = $Sounds/LaserSound
@onready var laser_sound3: AudioStreamPlayer2D = $Sounds/LaserSound
@onready var hit_sound: AudioStreamPlayer2D = $Sounds/Hit
@onready var hit_sound2: AudioStreamPlayer2D = $Sounds/Hit2
@onready var hit_sound3: AudioStreamPlayer2D = $Sounds/Hit3
@onready var hit_sound4: AudioStreamPlayer2D = $Sounds/Hit4
@onready var burn_sound: AudioStreamPlayer2D = $Sounds/Burn
@onready var collide_sound: AudioStreamPlayer2D = $Sounds/Collide
@onready var select_sound: AudioStreamPlayer2D = $Sounds/Select
@onready var charge_sound: AudioStreamPlayer2D = $Sounds/ChargeSound
@onready var explosion_sound: AudioStreamPlayer2D = $Sounds/ExplosionSound
@onready var pickup_sound: AudioStreamPlayer2D = $Sounds/PickupSound
@onready var pickup_sound2: AudioStreamPlayer2D = $Sounds/PickupSound2
@onready var pickup_sound3: AudioStreamPlayer2D = $Sounds/PickupSound3
@onready var pickup_sound4: AudioStreamPlayer2D = $Sounds/PickupSound4
@onready var invalid_sound: AudioStreamPlayer2D = $Sounds/InvalidSound
@onready var crosshair: Sprite2D = $Sprite2D/CrosshairSprite
@onready var beacon_vector: Sprite2D = $Vector/Beacons/Sprite2D


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
	if not ship_body.is_cpu and Blast.data.settings.show_crosshairs == 1:
		crosshair.modulate = CROSSHAIR_WHITE
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
	create_enemy_ship_vectors()


func create_enemy_ship_vectors() -> void:
	for i in range( ship_body.game.ships.size() ):
		var ship = ship_body.game.ships[ i ]
		if ship != ship_body and not enemies.has( ship ):
			var ship_vector: Sprite2D
			var ship_vector_front: Sprite2D
			if i >= ship_vectors.get_child_count():
				ship_vector = Sprite2D.new()
				ship_vector_front = Sprite2D.new()
				ship_vector.add_child( ship_vector_front )
				ship_vectors.add_child( ship_vector )
			else:
				ship_vector = ship_vectors.get_child( i )
				ship_vector_front = ship_vector.get_child( 0 )
			ship_vector_front.position.x = -0.5
			ship_vector_front.scale = Vector2( 0.75, 0.75 )
			ship_vector_front.texture = ship_body.game.TRI_IMAGE
			ship_vector_front.modulate = ship.ui_color
			ship_vector.texture = ship_body.game.TRI_IMAGE
			ship_vector.self_modulate.a = 0
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
	burn_particles.emitting = ship_body.is_burning
	if is_main_ship:
		update_main_ship( delta )
	update_sounds()


func update_sounds() -> void:
	if ship_body.start_thrusting and not thrust_sound.playing:
		thrust_sound.play()
	if ship_body.stop_thrusting:
		thrust_sound.stop()
	if ship_body.is_laser_firing:
		laser_sounds.pick_random().play()
	if ship_body.is_shields_hit:
		shield_hit_sounds.pick_random().play()
	if ship_body.is_body_hit:
		body_hit_sounds.pick_random().play()
	if ship_body.is_burning and not burn_sound.playing:
		burn_sound.play()
	if ship_body.collide_sound_volume > 0:
		collide_sound.volume_db = ship_body.collide_sound_volume
		if not collide_sound.playing:
			collide_sound.play()
	if ship_body.is_selecting and not select_sound.playing:
		select_sound.play()
	if ship_body.is_charging and not charge_sound.playing:
		charge_sound.play()
	elif not ship_body.is_charging:
		charge_sound.stop()


func update_main_ship( delta: float ) -> void:
	
	# Update Stars
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
	
	# Update ship vectors
	for i in range( enemies.size() ):
		var ship: BlastShipBody = enemies[ i ]
		var ship_vector = ship_vectors.get_child( i )
		update_vector( ship_vector, ship.position )
		#var ship_diff = ( ship.position - position )
		#var ship_vector_pos = ship_diff.normalized() * 75
		#var a = 1.0 - ship_diff.length_squared() * 0.0000001
		#ship_vector.position = ship_vector_pos
		#ship_vector.rotation = ship_vector_pos.angle()
		#ship_vector.modulate.a = clampf( a, 0.6, 1.0 )
		#ship_vector.scale = Vector2( ship_vector.modulate.a, ship_vector.modulate.a )
		#if a > 0.94:
			#ship_vector.self_modulate.a = 1
		#else:
			#ship_vector.self_modulate.a = 0
		if ship.is_game_over:
			ship_vector.hide()
	
	# Update beacon vector
	beacon_vector.modulate.a = 0
	if target_beacon:
		beacon_vector.modulate = target_beacon.modulate
		update_vector( beacon_vector, target_beacon.position, true )
	
	#if ship_body.speed < 15625:
		#pos = ship_body.linear_velocity
	#else:
		#pos = ship_body.linear_velocity.normalized() * 50
	vector_sprite.position = pos
	vector_sprite.rotation = ship_body.linear_velocity.angle()
	camera_pos = pos
	camera.position = camera.position.lerp( camera_pos, 0.5 * delta )
	
	process_low_energy_warning( delta )
	
	# Adjust camera zoom to zoom out when moving fast
	var speed_factor = ( ( 15 - clampf( log( ship_body.speed ), 10, 15 ) ) / 5 ) * ZOOM_SIZE
	var zoom_factor = 1 - ( ZOOM_SIZE - speed_factor )
	var zdx: float = ZOOM_DX * delta
	if camera.zoom.x + zdx < zoom_factor:
		camera.zoom.x += zdx
	elif camera.zoom.x - zdx > zoom_factor:
		camera.zoom.x -= zdx
	else:
		camera.zoom.x = zoom_factor
	camera.zoom.y = camera.zoom.x
	
	# Show stats
	$Label.text = "%s" % camera.zoom.x
	#$Label.text = "%s" % log( ship_body.speed )
	#$Label.text = "%d / %d / %d" % [ ship_body.shields, ship_body.health, ship_body.energy ]
	#$Label.text = "%d" % ship_body.speed
	#$Label.text = "%d" % sqrt( ship_body.speed )
	#$Label.text = "%d" % rad_to_deg( ship_body.rotation_speed )
	#$Label.text = "%d" % rad_to_deg( Globals.normalize_angle( ship_body.rotation ) )
	#$Label.text = "%d - %d" % [
		#rad_to_deg( Globals.normalize_angle( ship_body.rotation ) ),
		#rad_to_deg( Globals.normalize_angle( ship_body.linear_velocity.angle() ) )
	#]
	#$Label.text = "(%d, %d)" % [
		#roundi( ship_body.position.x / 100 ),
		#roundi( ship_body.position.y / 100 )
	#]
	
	if ship_body.is_cpu:
		var state_name = ship_body.cpu_ai.state_name
		var substate_name = ship_body.cpu_ai.state.substate_name
		$Label.text = "%s - %s" % [ state_name, substate_name ]


func update_vector( vector: Sprite2D, pos: Vector2, is_beacon: bool = false ) -> void:
	var diff = ( pos - position )
	var vector_pos = diff.normalized() * 75
	var a = 1.0 - diff.length_squared() * 0.0000001
	vector.position = vector_pos
	vector.rotation = vector_pos.angle()
	vector.modulate.a = clampf( a, 0.6, 1.0 )
	if is_beacon: vector.modulate.a = clampf( a, 0.8, 1.0 )
	vector.scale = Vector2( vector.modulate.a, vector.modulate.a )
	#if a > 0.94:
		#vector.self_modulate.a = 1
	#else:
		#vector.self_modulate.a = 0


func process_low_energy_warning( delta: float ) -> void:
	if ship_body.energy < ship_body.max_energy * LOW_ENERGY_WARN_PCT:
		if ship_body.is_destroyed:
			low_energy_sprite.modulate.a = 0
			return
		var da: float = delta * 1.5
		if ship_body.energy < ship_body.max_energy * LOW_ENERGY_WARN_PCT2:
			da *= blink_d
			low_energy_sprite.modulate.a = clampf( low_energy_sprite.modulate.a + da, 0.35, 1.0 )
			var a = low_energy_sprite.modulate.a
			if low_energy_sprite.modulate.a == 1.0:
				blink_d = -1.0
			elif low_energy_sprite.modulate.a <= 0.35:
				blink_d = 1.0
		elif ship_body.energy < ship_body.max_energy * LOW_ENERGY_WARN_PCT:
			low_energy_sprite.modulate.a = minf( low_energy_sprite.modulate.a + da, 0.75 )
	else:
		low_energy_sprite.modulate.a = maxf( low_energy_sprite.modulate.a - delta, 0.0 )


func raise_shields() -> void:
	shield_particles.emitting = true


func show_health_bar() -> void:
	if health_bar_tween != null and health_bar_tween.is_running():
		health_bar_tween.stop()
	health_bar.value = ship_body.health / ship_body.max_health * 100.0
	health_bar_tween = create_tween()
	health_bar_tween.tween_property( health_bar_panel, "modulate:a", 1.0, 0.5 )
	health_bar_tween.tween_property( health_bar_panel, "modulate:a", 1.0, 1.5 )
	health_bar_tween.tween_property( health_bar_panel, "modulate:a", 0.0, 1.0 )


func hide_health_bar() -> void:
	if health_bar_tween != null and health_bar_tween.is_running():
		health_bar_tween.stop()
	health_bar_tween = create_tween()
	health_bar_tween.tween_property( health_bar_panel, "modulate:a", 0.0, 0.5 )


func show_crosshair() -> void:
	if is_crosshair_green:
		return
	if crosshair_tween != null and crosshair_tween.is_running():
		crosshair_tween.stop()
	crosshair_tween = create_tween()
	crosshair_tween.tween_property( crosshair, "modulate", CROSSHAIR_GREEN, 0.35 )
	is_crosshair_green = true


func hide_crosshair() -> void:
	if not is_crosshair_green:
		return
	if crosshair_tween != null and crosshair_tween.is_running():
		crosshair_tween.stop()
	crosshair_tween = create_tween()
	crosshair_tween.tween_property( crosshair, "modulate", CROSSHAIR_WHITE, 0.35 )
	is_crosshair_green = false


func _ready() -> void:
	rockets = [
		$Sprite2D/Rockets/Rocket/RocketParticles,
		$Sprite2D/Rockets/Rocket/RocketParticles2,
		$Sprite2D/Rockets/Rocket2/RocketParticles,
		$Sprite2D/Rockets/Rocket2/RocketParticles2
	]
	beacon_vector.modulate.a = 0
	crosshair.modulate.a = 0
	low_energy_sprite.modulate.a = 0
	health_bar_panel.modulate.a = 0
	laser_sounds = [ laser_sound, laser_sound2, laser_sound3 ]
	shield_hit_sounds = [ hit_sound, hit_sound2 ]
	body_hit_sounds = [ hit_sound3, hit_sound4 ]
	pickup_sounds = [ pickup_sound, pickup_sound2, pickup_sound3, pickup_sound4 ]
	
	# Modify sounds based on number of players
	var displacement: float = 0
	if Blast.data.player_count == 2:
		displacement = -1
	elif Blast.data.player_count == 3:
		displacement = -3
	elif Blast.data.player_count == 4:
		displacement = -6
	for sound: AudioStreamPlayer2D in $Sounds.get_children():
		sound.volume_db = sound.volume_db + displacement
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
