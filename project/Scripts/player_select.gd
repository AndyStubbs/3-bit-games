extends Panel
class_name RAF_PlayerSelect


enum GAME_TYPE {
	TUN, RAF, BLAST
}


const SWAP_COLORS: Array = [
	Color.BLACK,
	Color.WHITE,
	Color( 0.5, 0.5, 0.5 )
]
const RAF_DATA = [ Vector2( 2, 2 ), 18, 0 ]
const TUN_DATA = [ Vector2( 7, 7 ), 22, 90 ]
const BLAST_DATA = [ Vector2( 1, 1 ), 22, 0 ]


@export var game_type: GAME_TYPE = GAME_TYPE.RAF
@export var player_id: int = 0


var CONTROL_NAMES: Dictionary = {
	"P0": "TR_WASD",
	"P1": "TR_ARROWS",
	"ANY": "TR_ALL_CONTROLS",
	"CPU": "TR_CPU",
	"J0": "TR_GAMEPAD_0",
	"J1": "TR_GAMEPAD_1",
	"J2": "TR_GAMEPAD_2",
	"J3": "TR_GAMEPAD_3"
}
var CONTROL_IDS: Dictionary = {
	"TR_WASD": "P0",
	"TR_ARROWS": "P1",
	"TR_ALL_CONTROLS": "ANY",
	"TR_CPU": "CPU",
	"TR_GAMEPAD_0": "J0",
	"TR_GAMEPAD_1": "J1",
	"TR_GAMEPAD_2": "J2",
	"TR_GAMEPAD_3": "J3"
}
var DEFAULT_CONTROLS: Array = [
	"P0",
	"P1",
	"ANY",
	"CPU"
]


var player_settings: Dictionary = {}
var base_image: Image
var is_loading: bool = true
var last_name: String


@onready var player_enabled: CheckButton = $MC/VB/Control/PlayerEnabled
@onready var name_text: LineEdit = $MC/VB/VB/NameText
@onready var control_select: OptionButton = $MC/VB/VB/ControlSelect
@onready var left_button: Button = $MC/VB/VB/HB/LeftButton
@onready var right_button: Button = $MC/VB/VB/HB/RightButton
@onready var player_image: Sprite2D = $MC/VB/VB/HB/PlayerImage
@onready var player_image2: Sprite2D = $MC/VB/VB/HB/PlayerImage2


func _ready() -> void:
	player_settings = Globals.players[ player_id ]
	var style: StyleBoxFlat = get_theme_stylebox( "panel" )
	style.bg_color = Color( "#0f5a89" )
	player_image.modulate = Color.WHITE
	player_image2.hide()
	if game_type == GAME_TYPE.RAF:
		player_image.texture = Globals.RAF_IMAGES[ 0 ]
		player_image.scale = RAF_DATA[ 0 ]
		player_image.position.y = RAF_DATA[ 1 ]
		player_image.rotation = deg_to_rad( RAF_DATA[ 2 ] )
	elif game_type == GAME_TYPE.TUN:
		player_image.texture = Globals.TUN_IMAGES[ 0 ]
		player_image.scale = TUN_DATA[ 0 ]
		player_image.position.y = TUN_DATA[ 1 ]
		player_image.rotation = deg_to_rad( TUN_DATA[ 2 ] )
	elif game_type == GAME_TYPE.BLAST:
		style.bg_color = Color.BLACK
		player_image.modulate = Color( 0, 0, 0 )
		player_image.texture = Globals.BLAST_IMAGES[ player_settings.image_id ][ 0 ]
		player_image.scale = BLAST_DATA[ 0 ]
		player_image.position.y = BLAST_DATA[ 1 ]
		player_image.rotation = deg_to_rad( BLAST_DATA[ 2 ] )
		player_image2.show()
		player_image2.texture = Globals.BLAST_IMAGES[ player_settings.image_id ][ 1 ]
		player_image2.scale = BLAST_DATA[ 0 ]
		player_image2.position.y = BLAST_DATA[ 1 ]
		player_image2.rotation = deg_to_rad( BLAST_DATA[ 2 ] )
	Input.joy_connection_changed.connect( joy_connection_changed )
	init()


func _on_player_enabled_toggled( _toggled_on: bool ) -> void:
	update_settings()


func _on_control_select_item_selected( _index: int ) -> void:
	update_settings()


func _on_right_button_pressed() -> void:
	player_settings.colors += 1
	if player_settings.colors >= Globals.PLAYER_COLORS.size():
		player_settings.colors = 0
		if game_type == GAME_TYPE.BLAST:
			player_settings.image_id += 1
			if player_settings.image_id >= Globals.BLAST_IMAGES.size():
				player_settings.image_id = 0
	update_settings()


func _on_left_button_pressed() -> void:
	player_settings.colors -= 1
	if player_settings.colors < 0:
		player_settings.colors = Globals.PLAYER_COLORS.size() - 1
		if game_type == GAME_TYPE.BLAST:
			player_settings.image_id -= 1
			if player_settings.image_id < 0:
				player_settings.image_id = Globals.BLAST_IMAGES.size() - 1
	update_settings()


func joy_connection_changed( _device: int, _connected: bool ) -> void:
	update_controllers()


func init() -> void:
	load_settings()
	is_loading = false
	var img = player_image.texture.get_image()
	base_image = Image.create( img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8 )
	base_image.copy_from( img )
	update_image_colors()
	update_ui_state()
	update_controllers()


func load_settings() -> void:
	if player_settings.name_changed:
		name_text.text = player_settings.name
	else:
		name_text.text = tr( player_settings.name )
	last_name = name_text.text
	player_enabled.button_pressed = player_settings.enabled
	load_controller_setting()


func load_controller_setting() -> void:
	for i in range( control_select.item_count ):
		var id = control_select.get_item_metadata( i )
		if id == player_settings.controls:
			control_select.select( i )
			break


func update_image_colors() -> void:
	if game_type == GAME_TYPE.BLAST:
		player_image.texture = Globals.BLAST_IMAGES[ player_settings.image_id ][ 0 ]
		var color = Globals.BLAST_COLORS[ player_settings.colors ]
		player_image2.texture = Globals.BLAST_IMAGES[ player_settings.image_id ][ 1 ]
		player_image2.modulate = color
		return
	var image = player_image.texture.get_image()
	image.copy_from( base_image )
	var pc: Array = []
	pc.append_array( Globals.PLAYER_COLORS[ player_settings.colors ] )
	if game_type == GAME_TYPE.TUN:
		pc[ 0 ] = pc[ 1 ].darkened( 0.25 )
		pc[ 2 ] = pc[ 1 ].lightened( 0.25 )
	Globals.swap_colors_img( image, pc, SWAP_COLORS )
	player_image.texture = ImageTexture.create_from_image( image )


func update_settings() -> void:
	if is_loading: return
	player_settings.enabled = player_enabled.button_pressed
	if player_settings.name_changed:
		player_settings.name = name_text.text
	var id = control_select.get_selected_id()
	if id > -1:
		var control_id = control_select.get_item_metadata( id )
		player_settings.controls = control_id
	update_ui_state()
	Globals.update_player_settings( player_settings )


func update_ui_state() -> void:
	if player_settings.enabled:
		name_text.editable = true
		control_select.disabled = false
		left_button.disabled = false
		right_button.disabled = false
		update_image_colors()
		player_image.modulate = Color( 1, 1, 1, 1 )
	else:
		name_text.editable = false
		control_select.disabled = true
		left_button.disabled = true
		right_button.disabled = true
		if game_type == GAME_TYPE.BLAST:
			player_image.modulate = Color( 0.5, 0.5, 0.5, 0.25 )
			player_image2.modulate = Color( 0.5, 0.5, 0.5, 0.25 )
			return
		var img = player_image.texture.get_image()
		img.copy_from( base_image )
		player_image.texture.update( img )
		player_image.modulate = Color( 0.5, 0.5, 0.5, 0.25 )


func update_controllers() -> void:
	control_select.clear()
	var id: int = 0
	for controller in DEFAULT_CONTROLS:
		control_select.add_item( tr( CONTROL_NAMES[ controller ] ), id )
		control_select.set_item_metadata( id, controller )
		id += 1
	for j_id in Input.get_connected_joypads():
		var gamepad_id = "J%s" % j_id
		control_select.add_item( tr( CONTROL_NAMES[ gamepad_id ] ) )
		control_select.set_item_metadata( id, gamepad_id )
		id += 1
	load_controller_setting()


func _on_name_text_text_changed( _new_text: String ) -> void:
	if last_name != _new_text:
		player_settings.name_changed = true
		last_name = _new_text
	update_settings()


func _on_name_text_text_submitted( _new_text: String ) -> void:
	if last_name != _new_text:
		player_settings.name_changed = true
		last_name = _new_text
	update_settings()
	name_text.release_focus()


func _on_reset_button_pressed() -> void:
	player_settings = Globals.get_default_player_settings( player_settings.id )
	load_settings()
	update_settings()
