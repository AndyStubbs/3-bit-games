extends Node2D
class_name RAF_Bullet


const BULLET_SCENE: PackedScene = preload( "res://Games/ReadyAimFire/Scenes/bullet.tscn" )
const EXPLOSION_SCENE = preload( "res://Games/ReadyAimFire/Scenes/explosion.tscn" )
const PARTICLE_SCENE = preload( "res://Games/ReadyAimFire/Scenes/my_particle.tscn" )
const MINE_SCENE: PackedScene = preload( "res://Games/ReadyAimFire/Scenes/mine.tscn" )
const MAX_TIME: float = 10.0
const BOUNCINESS: float = 1.0


var level: RAF_Level
var velocity: Vector2 = Vector2.ZERO
var last_pos: Vector2
var is_alive: bool = true
var explosion: RAF_Explosion
var fired_from: RAF_Tank
var is_missile: bool = false
var is_rocket_fired: bool = false
var rocket_target: RAF_Tank
var elapsed: float = 0
var bullet_data: Dictionary
var is_cluster: bool = false
var is_main_bullet: bool = true
var is_spinning: bool = false
var wired_time: float = 0


@onready var sprite: Sprite2D = $Sprite2D


func init( new_level: RAF_Level, source_tank: RAF_Tank, bullet_type: Raf.BULLET_TYPES ) -> void:
	level = new_level
	if bullet_type != Raf.BULLET_TYPES.MINI_CLUSTER:
		level.on_bullet_spawned.emit( self )
	fired_from = source_tank
	bullet_data = Raf.bullet_data[ bullet_type ]
	modulate = bullet_data.modulate
	sprite.scale = Vector2( bullet_data.bullet_scale, bullet_data.bullet_scale )
	sprite.texture = bullet_data.image
	if bullet_data.type == "missile":
		is_missile = true
		is_rocket_fired = false
	elif bullet_data.type == "cluster":
		is_cluster = true
	if bullet_data.has( "potion" ):
		is_spinning = true


func fire( angle: float, speed: float ) -> void:
	wired_time = Time.get_ticks_msec() + 100
	velocity = Vector2( cos( angle ) * speed, sin( angle ) * speed )
	elapsed = 0


func _physics_process( delta: float ) -> void:
	elapsed += delta
	if elapsed > MAX_TIME and is_alive:
		explode( null )
		return
	last_pos = position
	if is_rocket_fired:
		process_rocket( delta )
	process_gravity( delta )
	var angle = velocity.angle()
	if is_spinning:
		sprite.rotation += delta * -3
	else:
		sprite.rotation = angle
	if detect_ground_collision():
		explode( null )
	if is_cluster and detect_near_ground( delta, bullet_data.cluster_distance ):
		fire_clusters()


func fire_clusters() -> void:
	sprite.texture = Raf.MINI_CLUSTER_IMAGE
	is_cluster = false
	$SplitSound.play()
	var rotations: Array = [ PI / 4,  ( 3 * PI ) / 4, PI + PI / 4, -PI / 4 ]
	for rot in rotations:
		var bullet = BULLET_SCENE.instantiate()
		var power: float = 300
		get_parent().add_child( bullet )
		bullet.position = position
		bullet.init( level, fired_from, Raf.BULLET_TYPES.MINI_CLUSTER )
		bullet.velocity = velocity + Vector2( cos( rot ) * power, sin( rot ) * power )
		bullet.elapsed = 0
		bullet.is_main_bullet = false
		elapsed = 0


func process_rocket( delta: float ) -> void:
	if position.x < -100 and velocity.x < 0:
		destroy_bullet()
	elif position.x > level.width * level.scale + 100 and velocity.x > 0:
		destroy_bullet()
	find_target()
	if rocket_target == null:
		rocket_target = fired_from
	var target_position = rocket_target.position
	var direction = ( target_position - position ).normalized()
	var normal_velocity = velocity.normalized()
	var acc = Vector2.ZERO
	if direction.y > normal_velocity.y:
		acc = ( normal_velocity + Vector2( 0, 1 ) ).normalized() * 1500
	else:
		acc = ( normal_velocity + Vector2( 0, -1 ) ).normalized() * 1500
	velocity += acc * delta


func find_target() -> void:
	var min_distance = INF
	for tank: RAF_Tank in level.tanks:
		if tank != fired_from:
			var distance = position.distance_squared_to( tank.position )
			if distance < min_distance:
				rocket_target = tank
				min_distance = distance


func process_gravity( delta: float ) -> void:
	var ratio = ( level.height - ( position.y / level.scale ) ) / level.height
	var wind = level.wind * ratio
	position += ( velocity + wind ) * delta
	velocity += level.gravity
	if is_missile and not is_rocket_fired and velocity.y > 0:
		$Sprite2D/Rocket/RocketParticles.emitting = true
		$Sprite2D/Rocket/RocketParticles2.emitting = true
		$RocketSound.play()
		is_rocket_fired = true


func simulate_gravity( delta: float, data: Dictionary) -> void:
	var ratio = ( level.height - ( data.pos.y / level.scale ) ) / level.height
	var wind = level.wind * ratio
	data.pos += ( data.vel + wind ) * delta
	data.vel += level.gravity


func explode( tank_hit: RAF_Tank ) -> void:
	if not is_alive:
		if explosion != null and bullet_data.has( "explosion_scale" ):
			explosion.hits.append( tank_hit )
		return
	is_alive = false
	if bullet_data.has( "mine" ):
		var mine = MINE_SCENE.instantiate()
		get_parent().call_deferred( "add_child", mine )
		mine.init( level, bullet_data )
		mine.position = position
		mine.rotation = rotation
		destroy_bullet()
		return
	if bullet_data.has( "explosion_scale" ):
		explosion = EXPLOSION_SCENE.instantiate()
		explosion.scale = Vector2( bullet_data.explosion_scale, bullet_data.explosion_scale )
		explosion.init( level, fired_from )
		explosion.hits.append( tank_hit )
		explosion.is_main_bullet = is_main_bullet
		explosion.force = bullet_data.force
		explosion.radius = bullet_data.radius
		explosion.points = bullet_data.points
		explosion.position = position
		explosion.position.y += 4
		if bullet_data.force >= Raf.BULLET_DATA[ Raf.BULLET_TYPES.SUPER_NUKE ].force:
			explosion.is_nuke2 = true
		elif bullet_data.force >= Raf.BULLET_DATA[ Raf.BULLET_TYPES.NUKE ].force:
			explosion.is_nuke = true
		if bullet_data.has( "potion" ):
			explosion.is_potion = true
		get_parent().add_child( explosion )
	if bullet_data.has( "particle_count" ):
		modulate.a = 0
		var sound: AudioStreamPlayer
		if bullet_data.particle_pattern == "slime":
			sound = $SlimeSound
		elif bullet_data.particle_pattern == "dirt":
			sound = $DirtSound
		sound.play()
		for i in range( bullet_data.particle_count ):
			var particle = PARTICLE_SCENE.instantiate()
			get_parent().add_child( particle )
			particle.position = position
			particle.init( level, bullet_data.particle_colors, bullet_data.particle_pattern )
		set_physics_process( false )
		await sound.finished
	if bullet_data.has( "bridge" ):
		modulate.a = 0
		$BridgeSound.play()
		level.on_bridge_landed.emit( position, velocity )
		await $BridgeSound.finished
	if bullet_data.has( "shovel" ):
		modulate.a = 0
		$ShovelSound.play()
		level.on_shovel_landed.emit( position, velocity )
		await $ShovelSound.finished
	destroy_bullet()


func detect_ground_collision() -> bool:
	var last: Vector2i = Vector2i(
		roundi( last_pos.x / level.scale ),
		roundi( last_pos.y / level.scale )
	)
	var pos: Vector2i = Vector2i(
		roundi( position.x / level.scale ),
		roundi( position.y / level.scale )
	)
	var points = Globals.get_points_on_line( last, pos )
	for i in range( points.size() ):
		var point: Vector2i = points[ i ]
		if point.x >= 0 and point.x < level.width and point.y >= 0 and point.y < level.height:
			var color = level.img.get_pixel( point.x, point.y )
			if color != Color.BLACK:
				var last_point: Vector2i = point
				if i > 0:
					last_point = points[ i - 1 ]
				position = Vector2( last_point.x * level.scale, last_point.y * level.scale )
				return true
	if pos.y > level.height:
		destroy_bullet()
	return false


func detect_near_ground( delta: float, distance: int ) -> bool:
	var data: Dictionary = {
		"pos": position,
		"vel": velocity
	}
	for i in range( distance ):
		simulate_gravity( delta, data )
		var x = roundi( data.pos.x / level.scale )
		var y = roundi( data.pos.y / level.scale )
		if x < 0 or x > level.width - 1 or y < 0 or y > level.height - 1:
			continue
		var color = level.img.get_pixel( x, y )
		if color != Color.BLACK:
			return true
	return false


func destroy_bullet( delay: float = 1.5 ) -> void:
	if is_cluster:
		delay *= 2
	if is_main_bullet:
		level.on_bullet_destroyed.emit()
		level.on_turn_ended.emit( delay )
	queue_free()


func _on_area_2d_area_entered( area: Area2D ) -> void:
	var grand_parent = area.get_parent().get_parent()
	if grand_parent.is_in_group( "RAF_Tank" ):
		if grand_parent == fired_from and Time.get_ticks_msec() < wired_time:
			return
		explode( grand_parent )
	#else:
		#explode( null )
