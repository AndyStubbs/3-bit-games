extends Panel
class_name RAF_AMMO_SELECT



const UNSELECTED_STYLE_BOX = preload( "res://Assets/Resources/unselected_style_box.tres" )
const HOVER_STYLE_BOX = preload( "res://Assets/Resources/hover_style_box.tres" )
const SELECTED_STYLE_BOX = preload( "res://Assets/Resources/selected_style_box.tres" )
const HOVER_SELECTED_STYLE_BOX = preload( "res://Assets/Resources/hover_selected_style_box.tres" )


@export var bullet_type: Raf.BULLET_TYPES = Raf.BULLET_TYPES.COPPER


var is_selected: bool = true
var is_hovered: bool = false


func _ready() -> void:
	$HB/AmmoImage.texture = Raf.bullet_data[ bullet_type ].ui_image
	$HB/AmmoLabel.text = Raf.bullet_data[ bullet_type ].text
	init()


func _on_mouse_entered() -> void:
	if is_selected:
		add_theme_stylebox_override( "panel", HOVER_SELECTED_STYLE_BOX )
	else:
		add_theme_stylebox_override( "panel", HOVER_STYLE_BOX )
	is_hovered = true


func _on_mouse_exited() -> void:
	if is_selected:
		add_theme_stylebox_override( "panel", SELECTED_STYLE_BOX )
	else:
		add_theme_stylebox_override( "panel", UNSELECTED_STYLE_BOX )
	is_hovered = false


func _input( _event: InputEvent ) -> void:
	if Input.is_action_just_pressed( "MouseDown" ):
		if is_hovered:
			is_selected = !is_selected
			update_ammo()
			if is_selected:
				add_theme_stylebox_override( "panel", HOVER_SELECTED_STYLE_BOX )
			else:
				add_theme_stylebox_override( "panel", HOVER_STYLE_BOX )


func init() -> void:
	if is_selected:
		add_theme_stylebox_override( "panel", SELECTED_STYLE_BOX )
	else:
		add_theme_stylebox_override( "panel", UNSELECTED_STYLE_BOX )


func update_ammo() -> void:
	Raf.update_ammo( bullet_type, is_selected )
