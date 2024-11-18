extends RefCounted
class_name RAF_CPU_AI


var tank: RAF_Tank
var input: Dictionary
var last_input: Dictionary =  {
	"is_action_pressed": {
		"Flip_CPU": false,
		"Left_CPU": false,
		"Right_CPU": false,
		"Up_CPU": false,
		"Down_CPU": false,
		"ToggleUp_CPU": false,
		"ToggleDown_CPU": false,
		"Fire_CPU": false
	}
}
var is_debug: bool = false
var is_boosting: bool = false
var is_moving: bool = false
var is_choosing_bullet: bool = false
var is_aiming: bool = false
var is_firing: bool = false
var move_dir: int = 0
var last_aim_change: float = 0
var target_power: float = 0
var min_distance: float = INF
var min_distance_angle: float = 0
var min_distance_power: float = 0
var min_pos: Vector2
var last_angle: float = 0
var start_aim_time: float = 0
var bullet_changes: int = 0
var boosting_end_time: float = 0
var total_ticks: int = 0
var start_range: int = 0


func init( new_tank: RAF_Tank ) -> void:
	tank = new_tank
	reset_input()


func reset_input() -> void:
	input = {
		"is_action_just_pressed": {
			"Flip_CPU": false,
			"Left_CPU": false,
			"Right_CPU": false,
			"Up_CPU": false,
			"Down_CPU": false,
			"ToggleUp_CPU": false,
			"ToggleDown_CPU": false,
			"Fire_CPU": false
		},
		"is_action_just_released": {
			"Flip_CPU": false,
			"Left_CPU": false,
			"Right_CPU": false,
			"Up_CPU": false,
			"Down_CPU": false,
			"ToggleUp_CPU": false,
			"ToggleDown_CPU": false,
			"Fire_CPU": false
		},
		"is_action_pressed": {
			"Flip_CPU": false,
			"Left_CPU": false,
			"Right_CPU": false,
			"Up_CPU": false,
			"Down_CPU": false,
			"ToggleUp_CPU": false,
			"ToggleDown_CPU": false,
			"Fire_CPU": false
		}
	}


func preprocess_inputs() -> void:
	for action in last_input.is_action_pressed.keys():
		last_input.is_action_pressed[ action ] = input.is_action_pressed[ action ]
	for action in input.is_action_pressed.keys():
		input.is_action_pressed[ action ] = false
	for action in input.is_action_just_released.keys():
		input.is_action_just_released[ action ] = false


func begin_turn() -> void:
	is_boosting = false
	is_moving = false
	is_choosing_bullet = false
	is_aiming = false
	is_firing = false
	move_dir = 0
	last_aim_change = 0
	target_power = 0
	min_distance = INF
	min_distance_angle = 0
	min_distance_power = 0
	min_pos = Vector2.ZERO
	last_angle = 0
	start_aim_time = 0
	bullet_changes = 0
	boosting_end_time = 0
	begin_choosing_bullet()


func begin_boosting() -> void:
	is_boosting = true
	boosting_end_time = Time.get_ticks_msec() + randf_range( 1000, 5000 )
	if tank.position.x < tank.BUFF_X * 2:
		move_dir = 1
	elif tank.position.x > tank.level.width * tank.level.scale - tank.BUFF_X * 2:
		move_dir = -1
	else:
		pick_random_move_dir()


func begin_moving() -> void:
	is_moving = true
	if is_moving:
		if randf_range( 0, 1 ) > 0.5:
			move_dir = -1
			if not tank.check_can_move( -1 ):
				move_dir = 1
		else:
			move_dir = 1
			if not tank.check_can_move( 1 ):
				move_dir = -1


func begin_choosing_bullet() -> void:
	is_choosing_bullet = true
	bullet_changes = randi_range( 0, tank.bullet_select.item_count )
	pick_random_move_dir()


func begin_aiming() -> void:
	start_aim_time = Time.get_ticks_msec()
	is_aiming = true
	if tank.cannon.rotation > 0:
		move_dir = -1
	else:
		move_dir = 1
	target_power = 0
	min_distance_power = 0.5
	min_distance = INF
	min_pos = Vector2.ZERO


func begin_shooting() -> void:
	is_aiming = false
	is_firing = true
	if is_debug:
		Globals.debug_circle(
			min_pos, Color.CORAL, tank.tank_radius, 10, tank.get_parent(), 15
		)


func pick_random_move_dir() -> void:
	if randf_range( 0, 1 ) > 0.5:
		move_dir = -1
	else:
		move_dir = 1


func process( delta: float ) -> void:
	preprocess_inputs()
	process_flip()
	if is_choosing_bullet:
		process_bullet_change()
	elif is_boosting:
		process_boosting()
	elif is_moving:
		process_moving()
	elif is_aiming:
		process_aim( delta )
	elif is_firing:
		process_firing()
	elif tank.is_turn and not input.is_action_pressed.Fire_CPU:
		input.is_action_pressed.Fire_CPU = true
	postprocess_inputs()


func process_flip() -> void:
	if not tank.is_grounded or not tank.can_drive:
		input.is_action_pressed.Flip_CPU = false
		return
	var is_tank_in_sight: bool = false
	for t2: RAF_Tank in tank.level.tanks:
		if t2 == tank:
			continue
		if tank.is_facing_left:
			if t2.position.x < tank.position.x:
				is_tank_in_sight = true
		else:
			if t2.position.x > tank.position.x:
				is_tank_in_sight = true
	if not is_tank_in_sight:
		if is_debug:
			print(
				"No tank in sight. Flipping tank. Current facing direction:",
				tank.is_facing_left
			)
		input.is_action_pressed.Flip_CPU = true


func process_bullet_change() -> void:
	if bullet_changes <= 0:
		is_choosing_bullet = false
		if tank.bullet_type == Raf.BULLET_TYPES.ROCKET_BOOST:
			begin_boosting()
		else:
			begin_moving()
	else:
		if move_dir > 0:
			if randf_range( 0, 1 ) < 0.05:
				bullet_changes -= 1
				input.is_action_pressed.ToggleUp_CPU = true
		else:
			if randf_range( 0, 1 ) < 0.05:
				bullet_changes -= 1
				input.is_action_pressed.ToggleDown_CPU = true


func process_boosting() -> void:
	if Time.get_ticks_msec() < boosting_end_time:
		if tank.movement_points_remaining > 0:
			input.is_action_pressed.Fire_CPU = true
			if move_dir < 0:
				input.is_action_pressed.Left_CPU = true
			else:
				input.is_action_pressed.Right_CPU = true


func process_moving() -> void:
	# 1% chance of randomly stopping
	var is_stopping = randf_range( 0, 1 ) < 0.01
	if ( 
		not tank.check_can_move( move_dir ) or
		tank.movement_points_remaining <= 0 or
		is_stopping
	):
		is_moving = false
		begin_aiming()
	else:
		if move_dir < 0:
			input.is_action_pressed.Left_CPU = true
		else:
			input.is_action_pressed.Right_CPU = true


func process_firing() -> void:
	if tank.fire_power <= target_power:
		if not tank.is_firing:
			last_input.is_action_pressed.Fire_CPU = false
		input.is_action_pressed.Fire_CPU = true
	else:
		is_firing = false


func process_aim( delta: float ) -> void:
	if tank.is_body_rotating:
		return
	total_ticks = 0
	for i in range( start_range, 100 ):
		var p = float( i ) / 100.0
		estimate_shot( p, delta )
		if not is_aiming:
			return
	start_range = 0
	if is_aiming:
		var angle = tank.cannon.rotation
		if Time.get_ticks_msec() > start_aim_time + 5000:
			var diff = angle - min_distance_angle
			if abs( diff ) < 0.01:
				target_power = min_distance_power
				begin_shooting()
				return
		if Time.get_ticks_msec() > start_aim_time + 10000:
			target_power = 0.5
			begin_shooting()
			return
		if Time.get_ticks_msec() > last_aim_change:
			if last_angle == angle:
				last_aim_change = Time.get_ticks_msec() + 1000
				if move_dir == 1:
					move_dir = -1
				else:
					move_dir = 1
			last_angle = angle
		if move_dir > 0:
			input.is_action_pressed.Up_CPU = true
		else:
			input.is_action_pressed.Down_CPU = true


func estimate_shot( fire_power: float, delta: float ) -> void:
	var angle = tank.get_bullet_rotation()
	var speed = tank.get_bullet_power( fire_power )
	var bullet_data = Raf.bullet_data[ tank.bullet_type ]
	var tick_count: int = 200
	if bullet_data.type == "laser":
		speed *= 2
		tick_count = 50
	var vel = Vector2( cos( angle ) * speed, sin( angle ) * speed )
	var pos: Vector2 = tank.fire_point.global_position
	var last_pos: Vector2 = Vector2.ZERO
	var is_draw: bool = randf_range( 0, 1 ) < 0.01
	var points: Array = []
	for i in tick_count:
		total_ticks += 1
		var ratio = ( tank.level.height - ( pos.y / tank.level.scale ) ) / tank.level.height
		var wind = tank.level.wind * ratio
		if bullet_data.type == "laser":
			pos += vel * delta
			var x = roundi( pos.x / tank.level.scale )
			if x < 0 or x > tank.level.width - 1:
				break
			var y = roundi( ( pos.y + 10 ) / tank.level.scale )
			if y > tank.level.height - 1 or y < 0:
				break
		else:
			pos += ( vel + wind ) * delta
			vel += tank.level.gravity
			var x = roundi( pos.x / tank.level.scale )
			if x < 0 or x > tank.level.width - 1:
				break
			var y = roundi( ( pos.y + 10 ) / tank.level.scale )
			if y > tank.level.heights[ x ]:
				break
		points.append( pos )
		if is_debug and is_draw and not last_pos.is_zero_approx():
			Globals.debug_line( last_pos, pos, Color( 1, 0, 0, 0.25 ), 2, tank.get_parent(), 3 )
		last_pos = pos
		for t2: RAF_Tank in tank.level.tanks:
			if t2 != tank:
				var distance = pos.distance_squared_to( t2.position )
				if distance < min_distance:
					min_distance_angle = tank.cannon.rotation
					min_distance = distance
					min_distance_power = fire_power
					min_pos = pos
					if min_distance <= tank.tank_radius_square:
						target_power = fire_power
						begin_shooting()
						if is_debug:
							Globals.debug_circle(
								pos, Color.WEB_GREEN, tank.tank_radius, 10, tank.get_parent(), 15
							)
							var last_point = null
							for point in points:
								if last_point:
									Globals.debug_line(
										last_point, point, Color.WEB_PURPLE, 3, tank.get_parent(), 15
									)
								last_point = point
						return
					if is_debug:
						Globals.debug_circle(
							pos, Color( 1, 1, 0, 0.5 ), tank.tank_radius, 2, tank.get_parent(), 2
						)


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
