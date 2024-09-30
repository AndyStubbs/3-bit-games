extends Sprite2D


const FAST_SPEED: float = 800.0
const SLOW_SPEED: float = 300.0
const SPEED_GROWTH: float = 500.0
const ALPHA: float = 0.5


var speed: float = SLOW_SPEED
var is_hidden: bool = false
var tween: Tween


func _ready() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	position = mouse_pos


func _exit_tree() -> void:
	Globals.is_cursor_mode = false
	Input.set_custom_mouse_cursor( null, Input.CURSOR_ARROW )


func _physics_process( delta: float ) -> void:
	if Globals.is_menu_page and (
		Input.is_action_pressed( "Left_J_ANY" ) or 
		Input.is_action_pressed( "Right_J_ANY" ) or 
		Input.is_action_pressed( "Up_J_ANY" ) or 
		Input.is_action_pressed( "Down_J_ANY" )
	):
		Globals.is_cursor_mode = true
	if Input.is_action_just_pressed( "Option" ):
		Globals.is_cursor_mode = !Globals.is_cursor_mode
	if not Globals.is_cursor_mode:
		if not is_hidden:
			toggle_visible()
		return
	if is_hidden:
		toggle_visible()
	var vector: Vector2 = Vector2(
		Input.get_axis( "Left_J_ANY", "Right_J_ANY" ),
		Input.get_axis( "Up_J_ANY", "Down_J_ANY" )
	)
	var last_pos: Vector2 = Vector2( position )
	#position += speed * vector * delta
	position = Vector2(
		clampf( position.x + speed * vector.x * delta, 0, 1920 ),
		clampf( position.y + speed * vector.y * delta, 0, 1080 )
	)
	if last_pos.is_equal_approx( position ):
		speed = SLOW_SPEED
	else:
		speed = clampf( speed + SPEED_GROWTH * delta, SLOW_SPEED, FAST_SPEED )
		var screen_coord = get_viewport_transform() * global_position
		Input.warp_mouse( screen_coord )
	if Input.is_action_just_pressed( "Fire_ANY" ):
		var a = InputEventMouseButton.new()
		var screen_coord = get_viewport_transform() * global_position
		a.position = screen_coord
		a.button_index = MOUSE_BUTTON_LEFT
		a.pressed = true
		Input.parse_input_event( a )
	if Input.is_action_just_released( "Fire_ANY" ):
		var a = InputEventMouseButton.new()
		var screen_coord = get_viewport_transform() * global_position
		a.position = screen_coord
		a.button_index = MOUSE_BUTTON_LEFT
		a.pressed = false
		Input.parse_input_event( a )


func _input( event: InputEvent ) -> void:
	if event is InputEventMouseMotion:
		position = event.position


func toggle_visible() -> void:
	if is_hidden:
		Input.set_custom_mouse_cursor( texture, Input.CURSOR_ARROW, Vector2( 23, 23 ) )
	else:
		Input.set_custom_mouse_cursor( null, Input.CURSOR_ARROW )
	is_hidden = !is_hidden
