extends RefCounted
class_name TUN_CPU_AI


enum STATE {
	IDLE,
	TRAVEL,
	FIRE,
	STUCK
}


const MAX_BLOCKED: int = 10
const MAX_STUCKED: int = 50
const ATTACK_RANGE: float = 35
const ATTACK_RANGE_SQUARED: float = ATTACK_RANGE * ATTACK_RANGE
const BASE_PURSUE: float = 60
const MAX_PURSUE_DISTANCE: float = 5000000
const FIRE_DURATION: float = 1000


var state: STATE = STATE.IDLE
var nav_points: Array = []
var nav_index: int = 0
var markers: Array = []
var tank: TUN_Tank
var fire_time: float = 0
var last_input: Dictionary = {
	"is_action_pressed": {
		"Fire": false,
		"Up": false,
		"Right": false,
		"Down": false,
		"Left": false
	}
}
var stuck_count: int = 0
var last_pos: Vector2i
var pursue_distance = 0
var base_pursue_distance = 0
var max_pursue_distance = 0
var ground: TUN_Ground


func _init( new_tank: TUN_Tank ) -> void:
	base_pursue_distance = BASE_PURSUE * ( Tun.settings.SIZE + 1 )
	pursue_distance = base_pursue_distance * base_pursue_distance
	tank = new_tank
	last_pos = Vector2i( tank.position )
	ground = Tun.ground


func reset() -> void:
	state = STATE.IDLE
	nav_points = []
	nav_index = 0


func process() -> void:
	preprocess_inputs()
	if Tun.game_data.tanks.size() == 2:
		pursue_distance = MAX_PURSUE_DISTANCE
	else:
		pursue_distance = base_pursue_distance * base_pursue_distance
	
	if tank.position.is_equal_approx( last_pos ):
		stuck_count += 1
	else:
		stuck_count = 0
	
	if stuck_count > MAX_STUCKED:
		state = STATE.STUCK
		var rnd = randf_range( 0, 1 )
		if rnd < 0.25:
			tank.remote_input.is_action_pressed.Right = true
		elif rnd < 0.5:
			tank.remote_input.is_action_pressed.Left = true
		
		rnd = randf_range( 0, 1 )
		if rnd < 0.25:
			tank.remote_input.is_action_pressed.Down = true
		elif rnd < 0.5:
			tank.remote_input.is_action_pressed.Up = true
	elif state == STATE.STUCK:
		state = STATE.IDLE
	
	# Detect enemies
	var c_tank_data = get_closest_tank_data()
	
	if state == STATE.IDLE:
		idle( c_tank_data )
	elif state == STATE.FIRE:
		fire( c_tank_data )
	elif state == STATE.TRAVEL:
		navigate( c_tank_data )
	
	postprocess_inputs()
	
	last_pos = Vector2i( tank.position )


func set_random_nav_point( base_point: Vector2i, d: int ) -> void:
	var target_id: Vector2i
	var target_pos: Vector2i
	var is_target_valid: bool = false
	
	# If low on energy and not previously blocked then set nav home
	# Tanks tend to get stuck around corners near there base so
	# added not blocked to get them unstuck when near there base
	if tank.energy < 50 and tank.blocked_count < MAX_BLOCKED:
		target_pos = tank.base.position + tank.base.size / 2
		target_id = target_pos / Tun.GRID_SIZE
	else:
		if tank.energy < 50:
			@warning_ignore( "integer_division" )
			d = d / 2
		var count = 0
		while not is_target_valid:
			target_pos = Vector2i(
				randi_range( base_point.x - d, base_point.x + d ),
				randi_range( base_point.y - d, base_point.y + d )
			)
			target_id = target_pos / Tun.GRID_SIZE
			is_target_valid = (
				ground.grid.is_in_boundsv( target_id ) and 
				not ground.grid.is_point_solid( target_id )
			)
			count += 1
			if count > 25:
				d += 1
				count = 0
	
	var from: Vector2i = tank.position / Tun.GRID_SIZE
	nav_points = ground.grid.get_point_path( from, target_id )
	nav_index = 0
	if nav_points.size() == 0:
		state = STATE.IDLE
	else:
		state = STATE.TRAVEL
		Tun.on_grid_path_generated.emit( nav_points, tank.color2 )
	
	tank.blocked_count = 0


func idle( c_tank_data: Dictionary ) -> void:
	if tank.is_in_own_base and tank.energy < 75:
		pass
	else:
		if c_tank_data.tank != null:
			if c_tank_data.d < ATTACK_RANGE_SQUARED:
				attack( c_tank_data )
			elif state == STATE.IDLE and c_tank_data.d < pursue_distance:
				pursue( c_tank_data )
			else:
				set_random_nav_point( tank.position, 100 )
		else:
			set_random_nav_point( tank.position, 100 )


func navigate( c_tank_data: Dictionary ) -> void:
	
	# Stop moving if near an enemy 15% chance
	if c_tank_data.tank != null and c_tank_data.d < ATTACK_RANGE_SQUARED:
		if randf_range( 0, 1 ) < 0.15:
			state = STATE.IDLE
			return
	
	var nav_point: Vector2i = nav_points[ nav_index ]
	var distance = nav_point.distance_squared_to( tank.position )
	if distance < 16.0:
		nav_index += 1
		if nav_index >= nav_points.size():
			state = STATE.IDLE
			return
	
	if tank.blocked_count >= MAX_BLOCKED:
		state = STATE.IDLE
		return
	
	if nav_point.x > tank.position.x:
		tank.remote_input.is_action_pressed.Right = true
	elif nav_point.x < tank.position.x:
		tank.remote_input.is_action_pressed.Left = true
	
	if nav_point.y > tank.position.y:
		tank.remote_input.is_action_pressed.Down = true
	elif nav_point.y < tank.position.y:
		tank.remote_input.is_action_pressed.Up = true


func pursue( c_tank_data: Dictionary ) -> void:
	var target = c_tank_data.tank.position
	set_random_nav_point( target, roundi( ATTACK_RANGE - 5 ) )


func attack( c_tank_data: Dictionary ) -> void:
	var chance = 0.075
	if c_tank_data.d > 300:
		chance = 0.15
	if randf_range( 0, 1 ) < chance:
		aim( c_tank_data )
		fire_time = Time.get_ticks_msec()
		state = STATE.FIRE


func aim( c_tank_data: Dictionary ) -> void:
	var c_tank: TUN_Tank = c_tank_data.tank
	if c_tank.position.x > tank.position.x + 2:
		tank.remote_input.is_action_pressed.Right = true
	elif c_tank.position.x < tank.position.x - 2:
		tank.remote_input.is_action_pressed.Left = true
	
	if c_tank.position.y > tank.position.y + 2:
		tank.remote_input.is_action_pressed.Down = true
	elif c_tank.position.y < tank.position.y - 2:
		tank.remote_input.is_action_pressed.Up = true


func fire( c_tank_data: Dictionary ) -> void:
	if c_tank_data.tank == null:
		state = STATE.IDLE
	else:
		aim( c_tank_data )
		tank.remote_input.is_action_pressed.Fire = true
		if Time.get_ticks_msec() > fire_time + FIRE_DURATION:
			state = STATE.IDLE


func preprocess_inputs() -> void:
	
	# Store the state of is_action_pressed
	last_input.is_action_pressed.Fire = tank.remote_input.is_action_pressed.Fire
	last_input.is_action_pressed.Up = tank.remote_input.is_action_pressed.Up
	last_input.is_action_pressed.Down = tank.remote_input.is_action_pressed.Down
	last_input.is_action_pressed.Right = tank.remote_input.is_action_pressed.Right
	last_input.is_action_pressed.Left = tank.remote_input.is_action_pressed.Left
	
	# Reset remote_inputs for action pressed
	tank.remote_input.is_action_pressed.Fire = false
	tank.remote_input.is_action_pressed.Up = false
	tank.remote_input.is_action_pressed.Down = false
	tank.remote_input.is_action_pressed.Right = false
	tank.remote_input.is_action_pressed.Left = false
	
	# Reset remote_inputs for action just_released
	tank.remote_input.is_action_just_released.Fire = false
	tank.remote_input.is_action_just_released.Up = false
	tank.remote_input.is_action_just_released.Down = false
	tank.remote_input.is_action_just_released.Right = false
	tank.remote_input.is_action_just_released.Left = false


func postprocess_inputs() -> void:
	if not tank.remote_input.is_action_pressed.Fire and last_input.is_action_pressed.Fire:
		tank.remote_input.is_action_just_released.Fire = true
	if not tank.remote_input.is_action_pressed.Up and last_input.is_action_pressed.Up:
		tank.remote_input.is_action_just_released.Up = true
	if not tank.remote_input.is_action_pressed.Down and last_input.is_action_pressed.Down:
		tank.remote_input.is_action_just_released.Down = true
	if not tank.remote_input.is_action_pressed.Right and last_input.is_action_pressed.Right:
		tank.remote_input.is_action_just_released.Right = true
	if not tank.remote_input.is_action_pressed.Left and last_input.is_action_pressed.Left:
		tank.remote_input.is_action_just_released.Left = true


func get_closest_tank_data() -> Dictionary:
	if tank.energy < 5:
		return {
			"tank": null,
			"d": -1
		}
	
	var d = pursue_distance
	var closest_tank: TUN_Tank = null
	for e_tank: TUN_Tank in Tun.game_data.tanks:
		if e_tank != tank:
			var e_tank_d = tank.position.distance_squared_to( e_tank.position )
			if e_tank_d < d:
				closest_tank = e_tank
				d = e_tank_d
	return {
		"tank": closest_tank,
		"d": d
	}
