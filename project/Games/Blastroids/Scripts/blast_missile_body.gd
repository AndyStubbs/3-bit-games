extends RigidBody2D
class_name BlastMissileBody


var game: BlastGame
var damage: float
var clones: Array = []
var phase: int = 0
var phase_0_end: float = 0
var thrust_force: float = 400.0
var was_thrusting: bool = false
var is_thrusting: bool = false
var target: BlastShipBody
var rotation_speed = TAU * 1.5
var last_distance: float
var distance_check_time: float
var is_destroyed: bool = false
var energy: float = 1000
var drain: float = 100
var is_bomb: bool = false
var explosion_scale: Vector2 = Vector2( 1, 1 )
var fired_from_ship: BlastShipBody


@onready var sprite = $Sprite2D
@onready var marker = $Sprite2D/Sprite2D


func init( fired_from: BlastShipBody, weapon: String ) -> void:
	var weapon_data = BlastGame.WEAPONS_DATA[ weapon ]
	is_bomb = weapon_data.TYPE == "bomb"
	explosion_scale = weapon_data.EXPLOSION_SCALE
	energy = weapon_data.ENERGY
	mass = weapon_data.MASS
	sprite.scale = weapon_data.SCALE
	sprite.texture = weapon_data.IMAGE
	marker.texture = weapon_data.MARKER
	damage = weapon_data.DAMAGE
	fired_from_ship = fired_from
	game = fired_from_ship.game
	for i in range( game.worlds.size() ):
		var world = game.worlds[ i ]
		var clone: BlastMissile = game.scenes.MISSILE.instantiate()
		world.add_child( clone )
		clone.sprite.texture = sprite.texture
		clone.marker.texture = marker.texture
		clone.scale = sprite.scale
		clone.marker.modulate = sprite.modulate
		clones.append( clone )


func fire( new_velocity: Vector2, color: Color, new_rotation ) -> void:
	sprite.modulate = Color( color.r + 0.1, color.g + 0.1, color.b + 0.1, color.a )
	phase_0_end = Time.get_ticks_msec() + 600
	linear_velocity = new_velocity
	rotation = new_rotation
	await get_tree().create_timer( 0.2 ).timeout
	set_collision_layer_value( 1, true )
	set_collision_mask_value( 1, true )


func find_target() -> void:
	var min_distance = 1000 * 1000
	for target_ship: BlastShipBody in game.ships:
		if target_ship == fired_from_ship:
			continue
		var distance = position.distance_squared_to( target_ship.position )
		if distance < min_distance:
			target = target_ship
			min_distance = distance


func update_clones() -> void:
	var start_thrust: bool = is_thrusting and not was_thrusting
	var end_thrust: bool = not is_thrusting and was_thrusting
	for clone: BlastMissile in clones:
		clone.rotation = rotation
		clone.position = position
		clone.marker.modulate = sprite.modulate
		var rocket = clone.rocket
		if start_thrust:
			for gpu: GPUParticles2D in rocket.get_children():
				gpu.emitting = true
			clone.rocket_sound.play()
		elif end_thrust:
			for gpu: GPUParticles2D in rocket.get_children():
				gpu.emitting = false
			clone.rocket_sound.stop()


func get_clones() -> Array:
	return clones


func apply_thrust( delta: float ) -> void:
	is_thrusting = true
	var thrust_vector = Vector2.RIGHT.rotated( rotation ) * thrust_force
	apply_force( thrust_vector )
	energy -= drain * delta
	if energy < 0:
		game.on_missile_destroyed.emit()
		destroy()


func process_target( delta: float ) -> void:
	angular_velocity = 0
	var angle: float
	if target == null:
		angle = rotation
	else:
		var distance = position.distance_squared_to( target.position )
		if phase == 0:
			angle = calculate_target_angle( target )
		elif phase == 1:
			angle = calculate_rel_vel_angle( target )
		else:
			angle = calculate_target_angle( target )
			if Time.get_ticks_msec() > distance_check_time and distance < last_distance:
				phase = 1
		last_distance = distance
	var target_rotation = get_target_rotation( angle, delta )
	if target_rotation == 0:
		apply_thrust( delta )
	else:
		angular_velocity = target_rotation


func calculate_rel_vel_angle( body: RigidBody2D ) -> float:
	var relative_velocity = body.linear_velocity - linear_velocity
	if relative_velocity.length_squared() > 200:
		return relative_velocity.angle()
	else:
		phase = 2
		distance_check_time = Time.get_ticks_msec() + 1000
		return calculate_target_angle( body )


func calculate_target_angle( body: RigidBody2D ) -> float:
	var target_pos: Vector2 = body.position - position
	return atan2( target_pos.y, target_pos.x )


func get_target_rotation( target_angle: float, delta: float ) -> float:
	var current_angle = Globals.normalize_angle( rotation )
	target_angle = Globals.normalize_angle( target_angle )
	var vec1 = Vector2.from_angle( current_angle )
	var vec2 = Vector2.from_angle( target_angle )
	var between = vec1.angle_to( vec2 )
	if abs( between ) <= rotation_speed * delta:
		return 0
	if between > 0:
		if between > PI:
			return -rotation_speed
		else:
			return rotation_speed
	else:
		if between > PI:
			return rotation_speed
		else:
			return -rotation_speed


func destroy( body_hit = null ) -> void:
	if is_destroyed:
		return
	is_destroyed = true
	if explosion_scale.x > 2:
		for clone in clones:
			clone.explode_sound2.play()
	else:
		for clone in clones:
			clone.explode_sound.play()
	
	# Add Area explosion
	if is_bomb:
		var v = Vector2( explosion_scale * 8 )
		Globals.debug_circle( position, Color.DARK_RED, v.length(), 5, get_parent(), 5 )
		var exp_size = Vector2( explosion_scale * 8 ).length_squared()
		for body in game.bodies.get_children():
			if body != self and body != body_hit and body.has_method( "hit" ):
				var dist = ( body.position - position ).length_squared()
				if dist < exp_size:
					var d = damage * ( dist / exp_size )
					body.hit( d, fired_from_ship )
	
	# Create Explosion
	for world in game.worlds:
		var explosion = game.scenes.EXPLOSION.instantiate()
		explosion.scale = explosion_scale
		world.add_child( explosion )
		explosion.position = position
	
	# Stop Rocket Sounds and hide rocket
	for clone: BlastMissile in clones:
		clone.rocket_sound.stop()
		clone.sprite.modulate.a = 0
		for rocket: GPUParticles2D in clone.rocket.get_children():
			rocket.emitting = false
	
	# Stop everthing
	is_destroyed = true
	set_collision_layer_value( 1, false )
	set_collision_mask_value( 1, false )
	set_physics_process( false )
	set_process( false )
	
	# Wait until explosion sound is done
	if explosion_scale.x > 2:
		await clones[ 0 ].explode_sound2.finished
	else:
		await clones[ 0 ].explode_sound.finished
	
	# Queue free
	for clone in clones:
		clone.queue_free()
	clones = []
	queue_free()


func hit( _damage: float, fired_from: BlastShipBody ) -> void:
	if is_destroyed:
		return
	if fired_from != null:
		fired_from.stats.missile_kills += 1
	destroy()


func _physics_process( delta: float ) -> void:
	if is_destroyed:
		return
	is_thrusting = false
	if is_bomb:
		apply_thrust( delta )
	else:
		if phase == 0 and Time.get_ticks_msec() > phase_0_end:
			phase += 1
		if target == null:
			find_target()
		process_target( delta )
	update_clones()
	was_thrusting = is_thrusting


func _on_body_entered( body: Node ) -> void:
	if is_destroyed:
		return
	if body.has_method( "hit" ):
		body.hit( damage * sprite.modulate.a, fired_from_ship )
		if is_bomb:
			game.on_body_hit.emit( "bomb", body )
		else:
			game.on_body_hit.emit( "missile", body )
		if mass > 0:
			var r_body = body as RigidBody2D
			var diff = ( body.position - position )
			var normal = diff.normalized()
			r_body.apply_impulse( normal * mass, diff )
	if body.has_method( "get_clones" ):
		for clone in body.get_clones():
			var explosion = game.scenes.EXPLOSION.instantiate()
			explosion.scale = Vector2( 2, 2 )
			clone.add_child( explosion )
			explosion.global_position = global_position
	destroy( body )
