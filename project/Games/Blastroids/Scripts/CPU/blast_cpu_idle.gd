extends RefCounted
class_name BlastCpuIdle


const MOVE_LEN: float = 500.0
const OFFSET_LEN: float = 200.0
const MAX_MOVEMENT: float = 1000.0


var cpu: BlastCpuAi
var ship: BlastShipBody
var substate_name: String = ""


func init( new_cpu: BlastCpuAi ) -> void:
	cpu = new_cpu
	ship = cpu.ship


func start( _data: Variant ) -> void:
	pass


func process( _delta: float ) -> void:
	
	# Only attack if ship can fire
	if ship.can_cpu_fire():
		if proccess_attack():
			return
	
	# Random chance to move random position
	var chance: float = 0.75
	var target_pos: Vector2
	if randf_range( 0, 1 ) > chance:
		target_pos = get_random_position()
	else:
		target_pos = get_target_ship_position()
	
	# Check for collisions
	var collider = ship.shapecast_2d( target_pos )
	if collider:
		return
	
	# Set move position
	cpu.set_state( cpu.STATE.MOVE, target_pos )


func proccess_attack() -> bool:
	
	# Look for random ship targets - 75% chance
	var ship_attack_chance: float = 0.25
	if randf_range( 0, 1 ) > ship_attack_chance and ship.nearby_enemies.size() > 0:
		var target = ship.nearby_enemies.pick_random()
		cpu.set_state( cpu.STATE.ATTACK, target )
		return true
	
	# Look for random object targets
	var obj_attack_chance: float = 0.75
	if randf_range( 0, 1 ) > obj_attack_chance and ship.nearby_objs.size() > 0:
		var target = ship.nearby_objs.pick_random()
		cpu.set_state( cpu.STATE.ATTACK, target )
		return true
	
	return false


func get_random_position() -> Vector2:
	var pos = Vector2(
		ship.position.x + randf_range( -MOVE_LEN, MOVE_LEN ),
		ship.position.y + randf_range( -MOVE_LEN, MOVE_LEN )
	)
	return clamp_target( pos )


func clamp_target( pos: Vector2 ) -> Vector2:
	var rect = Blast.get_rect()
	var buffer = 100.0
	var min_x = rect.position.x + buffer
	var max_x = rect.position.x + rect.size.x - buffer
	var min_y = rect.position.y + buffer
	var max_y = rect.position.y + rect.size.y - buffer
	return Vector2(
		clampf( pos.x, min_x, max_x ),
		clampf( pos.y, min_y, max_y )
	)


func get_target_ship_position() -> Vector2:
	var target_ship: BlastShipBody = null
	var min_distance = INF
	
	# Find the nearest ship
	for check_ship: BlastShipBody in ship.game.ships:
		if ship != check_ship:
			var distance: float = ship.position.distance_squared_to( check_ship.position )
			if distance < min_distance:
				min_distance = distance
				target_ship = check_ship
	var pos = target_ship.position
	
	print( "%s Targeting %s" % [ ship.display_name, target_ship.display_name ] )
	
	# Make sure we don't set the target too far to avoid collisions
	if min_distance > 1000:
		var diff = target_ship.position - ship.position
		pos = ship.position + diff.normalized() * MAX_MOVEMENT
	
	# Add some random variation to movement so that we don't hit target directly
	# this will also add some varience incase there is an object in the way
	pos.x += randf_range( -OFFSET_LEN, OFFSET_LEN )
	pos.y += randf_range( -OFFSET_LEN, OFFSET_LEN )
	
	return clamp_target( pos )
