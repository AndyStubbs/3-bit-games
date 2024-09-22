extends RefCounted
class_name BlastCpuAi


enum STATE {
	IDLE,
	MOVE,
	ATTACK
}


var state
var states: Dictionary = {
	STATE.IDLE: BlastCpuIdle.new(),
	STATE.MOVE: BlastCpuMove.new(),
	STATE.ATTACK: BlastCpuAttack.new()
}
var ship: BlastShipBody
var input: Dictionary
var last_input: Dictionary =  {
	"is_action_pressed": {
		"Left_CPU": false,
		"Right_CPU": false,
		"Up_CPU": false,
		"Down_CPU": false,
		"Fire_CPU": false,
		"ToggleUp_CPU": false,
		"ToggleDown_CPU": false
	}
}
var ship_radius: float = 30.0


func init( new_ship: BlastShipBody ) -> void:
	ship = new_ship
	for st in states:
		states[ st ].init( self )
	reset_input()
	set_state( STATE.IDLE )


func reset_input() -> void:
	input = {
		"is_action_just_pressed": {
			"Left_CPU": false,
			"Right_CPU": false,
			"Up_CPU": false,
			"Down_CPU": false,
			"Fire_CPU": false,
			"ToggleUp_CPU": false,
			"ToggleDown_CPU": false
		},
		"is_action_just_released": {
			"Left_CPU": false,
			"Right_CPU": false,
			"Up_CPU": false,
			"Down_CPU": false,
			"Fire_CPU": false,
			"ToggleUp_CPU": false,
			"ToggleDown_CPU": false
		},
		"is_action_pressed": {
			"Left_CPU": false,
			"Right_CPU": false,
			"Up_CPU": false,
			"Down_CPU": false,
			"Fire_CPU": false,
			"ToggleUp_CPU": false,
			"ToggleDown_CPU": false
		}
	}


func set_state( new_state: STATE, data: Variant = null ) -> void:
	state = states[ new_state ]
	state.start( data )


func process( delta: float ) -> void:
	preprocess_inputs()
	
	# Check for collisions
	var collider = shapecast_2d( ship.position + ship.linear_velocity )
	if collider:
		Globals.debug_circle( collider.position, Color.RED, 15, 15, ship.get_parent(), 5 )
		input.is_action_pressed[ "Down_CPU" ] = true
	else:
		state.process( delta )
		
	# Check for targets
	if randf_range( 0, 1 ) > 0.75:
		collider = shapecast_2d( ship.position + Vector2.from_angle( ship.rotation ) * 600 )
		if collider:
			input.is_action_pressed[ "Fire_CPU" ] = true
	postprocess_inputs()


func preprocess_inputs() -> void:
	for action in last_input.is_action_pressed.keys():
		last_input.is_action_pressed[ action ] = input.is_action_pressed[ action ]
	for action in input.is_action_pressed.keys():
		input.is_action_pressed[ action ] = false
	for action in input.is_action_just_released.keys():
		input.is_action_just_released[ action ] = false


func postprocess_inputs() -> void:
	for action in input.is_action_pressed.keys():
		if input.is_action_pressed[ action ] and not last_input.is_action_pressed[ action ]:
			input.is_action_just_pressed[ action ] = true
		else:
			input.is_action_just_pressed[ action ] = false
	for action in input.is_action_pressed.keys():
		if not input.is_action_pressed[ action ] and last_input.is_action_pressed[ action ]:
			input.is_action_just_released[ action ] = true


func get_input( action: String, just: bool = false, released: bool = false ) -> bool:
	if just:
		return input.is_action_just_pressed[ action ]
	elif released:
		return input.is_action_just_released[ action ]
	else:
		return input.is_action_pressed[ action ]


func calculate_intercept_angle(
	position_a: Vector2, velocity_a: Vector2, position_b: Vector2, velocity_b: Vector2
) -> float:
	
	Globals.debug_circle(
		position_a, Color( 1, 0, 0, 0.1 ), 50, 5, ship.get_parent(), 5
	)
	Globals.debug_circle(
		position_b, Color( 0, 1, 0, 0.1 ), 50, 5, ship.get_parent(), 5
	)
	Globals.debug_line(
		position_a, position_b, Color( 1, 1, 1, 0.1 ), 5, ship.get_parent(), 5
	)
	
	# Relative position and velocity vectors
	var relative_position = position_b - position_a
	var relative_velocity = velocity_b - velocity_a
	
	# Magnitudes of the velocities
	var speed_a = velocity_a.length()
	
	# If the first rigidbody isn't moving, return a direct line
	if speed_a == 0:
		return atan2( relative_position.y, relative_position.x )
	
	# Solve for the intercept angle
	var a = relative_velocity.dot( relative_velocity ) - ( speed_a * speed_a )
	var b = 2 * relative_velocity.dot( relative_position )
	var c = relative_position.dot( relative_position )
	
	# Solve the quadratic equation for time
	var discriminant = b * b - 4 * a * c
	if discriminant < 0:
		return atan2( relative_position.y, relative_position.x )
	
	var t1 = ( -b + sqrt( discriminant ) ) / ( 2 * a )
	var t2 = ( -b - sqrt( discriminant ) ) / ( 2 * a )
	
	# Choose the positive time solution (future)
	var t = max( t1, t2 )
	
	# Future position of B at the intercept time
	var future_position_b = position_b + velocity_b * t
	
	# Direction vector from A to the future position of B
	var intercept_direction = ( future_position_b - position_a ).normalized()
	
	# Angle A needs to rotate towards to intercept B
	return intercept_direction.angle()


func shapecast_2d( end: Vector2 ) -> Variant:
	var shape_cast: ShapeCast2D = ship.shapecast
	shape_cast.rotation = -ship.rotation
	shape_cast.target_position = end - ship.position
	shape_cast.force_shapecast_update()
	Globals.debug_line( ship.position, end, Color.YELLOW, 2, ship.get_parent(), 1 )
	if shape_cast.is_colliding():
		return shape_cast.get_collider( 0 )
	return null
