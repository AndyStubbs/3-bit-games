extends Node2D


var current_angle
var is_ready: bool = true
var wait_time: float = 1


func _ready() -> void:
	var center: Vector2 = $Center.global_position
	for child in $Degs.get_children():
		var pos: Vector2 = child.global_position
		var diff = pos - center
		#var angle = rad_to_deg( center.angle_to( pos ) )
		#var angle = rad_to_deg( atan2( diff.y, diff.x ) )
		var angle = rad_to_deg( diff.angle() )
		child.get_node( "Label" ).text = "%d" % angle
	
	#current_angle = -PI / 4
	#var target_angle = PI / 4
	



func _physics_process( _delta: float ) -> void:
	if is_ready:
		test()
		is_ready = false
		await get_tree().create_timer( wait_time ).timeout
		is_ready = true


func test() -> void:
	current_angle = randf_range( -PI, PI )
	var target_angle = randf_range( -PI, PI )
	
	var vec_c = Vector2.from_angle( current_angle ) * 100
	var vec_t = Vector2.from_angle( target_angle ) * 100
	Globals.debug_line( Vector2.ZERO, vec_c, Color.WEB_GREEN, 10, self, wait_time + 1 )
	Globals.debug_line( Vector2.ZERO, vec_t, Color.DARK_RED, 10, self, wait_time + 1 )
	var dir = get_target_rotation( target_angle, 0.1 )
	draw_angles( dir )


func draw_angles( dir: float ) -> void:
	var a = current_angle
	var c = Color( 1, 1, 1 )
	for i in range( 100 ):
		a = wrapf( a + deg_to_rad( dir ), -PI, PI )
		var vec = Vector2.from_angle( a ) * 100
		Globals.debug_line( Vector2.ZERO, vec, c, 1, self, wait_time + 1 )
		c.a -= 0.05


func get_target_rotation( target_angle: float, delta: float ) -> float:
	var vec1 = Vector2.from_angle( current_angle )
	var vec2 = Vector2.from_angle( target_angle )
	var between = vec1.angle_to( vec2 )
	if abs( between ) < delta:
		return 0
	if between > 0:
		if between > PI:
			return -1
		else:
			return 1
	else:
		if between > PI:
			return 1
		else:
			return -1
	return 0
