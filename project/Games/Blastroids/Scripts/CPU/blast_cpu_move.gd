extends RefCounted
class_name BlastCpuMove


enum SUBSTATE {
	TARGETING,
	ROTATE,
	THRUST
}


var substate: SUBSTATE
var nav_point: Vector2
var cpu: BlastCpuAi
var ship: BlastShipBody
var target: Dictionary = {
	"angle": 0,
	"pos": Vector2.ZERO,
	"distance": 0,
	"halfway_distance": 0,
	"thrust_distance": 0,
	"action_time": 0
}


func init( new_cpu: BlastCpuAi ) -> void:
	cpu = new_cpu
	ship = cpu.ship


func start( data: Variant ) -> void:
	var pos = data as Vector2
	set_nav_point( pos )
	substate = SUBSTATE.TARGETING


func process( delta: float ) -> void:
	# Process the substate
	if substate == SUBSTATE.TARGETING:
		process_targeting( delta )
	elif substate == SUBSTATE.ROTATE:
		process_rotate( delta )
	elif substate == SUBSTATE.THRUST:
		process_thrust( delta )


func set_nav_point( pos: Vector2 ) -> void:
	nav_point = pos
	ship.nav_marker.global_position = pos


func process_targeting( _delta: float ) -> void:
	if nav_point.is_equal_approx( ship.position ):
		cpu.set_state( cpu.STATE.IDLE )
		return
	
	# Stop before moving towards target
	if ship.linear_velocity.is_zero_approx():
		target.obj = null
		target.pos = nav_point
		update_target()
		substate = SUBSTATE.ROTATE
	else:
		cpu.input.is_action_pressed[ "Down_CPU" ] = true


func process_rotate( delta ) -> void:
	update_target()
	var rot = ship.get_target_rotation( target.angle, delta )
	if rot < 0:
		cpu.input.is_action_pressed[ "Left_CPU" ] = true
	elif rot > 0:
		cpu.input.is_action_pressed[ "Right_CPU" ] = true
	else:
		ship.rotation = target.angle
		substate = SUBSTATE.THRUST


func process_thrust( _delta ) -> void:
	var distance_to_target: float = ship.position.distance_to( nav_point )
	
	# Close enough to target, set to idle
	if distance_to_target <= cpu.ship_radius:
		cpu.set_state( cpu.STATE.IDLE )
		return
	
	# We are off course, retarget
	if distance_to_target > target.distance:
		substate = SUBSTATE.TARGETING
		return
	
	# Thrusting
	if distance_to_target >= target.thrust_distance:
		cpu.input.is_action_pressed[ "Up_CPU" ] = true
	elif distance_to_target <= target.halfway_distance:
		if ship.linear_velocity.is_zero_approx():
			substate = SUBSTATE.TARGETING
		else:
			cpu.input.is_action_pressed[ "Down_CPU" ] = true
	
	# Update target distance
	target.distance = distance_to_target


func update_target() -> void:
	var distance = ship.position.distance_to( target.pos )
	target.angle = cpu.calculate_intercept_angle(
		ship.position, ship.linear_velocity, target.pos, Vector2.ZERO
	)
	target.distance = distance
	target.halfway_distance = distance / 2
	target.thrust_distance = target.halfway_distance + distance * 0.25
