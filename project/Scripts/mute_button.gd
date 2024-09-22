extends Control


var mute_image = load( "res://Assets/Images/mute_audio_icon.png" )
var audio_image = load( "res://Assets/Images/audio_icon.png" )
var is_shown: bool = false
var is_hovering: bool = false
var tween: Tween


func _ready() -> void:
	set_display()


func _on_mouse_entered() -> void:
	is_hovering = true


func _on_mouse_exited() -> void:
	is_hovering = false
	

func _input( _event: InputEvent ) -> void:
	if Input.is_action_just_pressed( "MouseDown" ):
		if is_hovering:
			Globals.is_mute = !Globals.is_mute
			set_display()


func set_display() -> void:
	if Globals.is_mute:
		AudioServer.set_bus_mute( AudioServer.get_bus_index( "Master" ), true )
		modulate.a = 0.35
		$TextureRect.texture = mute_image
	else:
		AudioServer.set_bus_mute( AudioServer.get_bus_index( "Master" ), false )
		modulate.a = 0.75
		$TextureRect.texture = audio_image
