extends RefCounted
class_name BlastCpuAttack



var cpu: BlastCpuAi
var ship: BlastShipBody
var target: Node2D
var target_offset: Vector2
var start_time: float
var substate_name: String = ""


func init( new_cpu: BlastCpuAi ) -> void:
	cpu = new_cpu
	ship = cpu.ship


func start( data: Variant ) -> void:
	target = data as Node2D
	start_time = Time.get_ticks_msec()
	get_random_target_offset()


func process( delta: float ) -> void:
	# Stop targeting if destroyed
	if (
		not target or
		not target.is_inside_tree() or
		target.is_destroyed or
		ship.position.distance_to( target.position ) > 500.0
	):
		cpu.set_state( cpu.STATE.IDLE )
		return
	if randf_range( 0, 1.0 ) > 0.95:
		get_random_target_offset()
	process_rotate( delta )
	if Time.get_ticks_msec() > start_time + 3000:
		cpu.set_state( cpu.STATE.IDLE )


func process_rotate( delta ) -> void:
	var angle = cpu.calculate_intercept_angle(
		ship.position, ship.linear_velocity, target.position + target_offset, Vector2.ZERO
	)
	var rot = ship.get_target_rotation( angle, delta )
	if rot < 0:
		cpu.input.is_action_pressed[ "Left_CPU" ] = true
	elif rot > 0:
		cpu.input.is_action_pressed[ "Right_CPU" ] = true
	else:
		ship.rotation = angle


func get_random_target_offset() -> void:
	target_offset = Vector2( randf_range( -50, 50 ), randf_range( -50, 50 ) )
