extends Node


@onready var audio_settings = $Control/AudioSettings
@onready var settings = $Control/HB
var is_fading: bool = false
var is_settings_mode: bool = false


func _ready() -> void:
	Globals.is_menu_page = true
	var sound_db = AudioServer.get_bus_volume_db( AudioServer.get_bus_index( "Sound" ) )
	$Control/AudioSettings/MC/VB/SoundSlider.value = db_to_linear( sound_db ) * 100
	var music_db = AudioServer.get_bus_volume_db( AudioServer.get_bus_index( "Music" ) )
	$Control/AudioSettings/MC/VB/MusicSlider.value = db_to_linear( music_db ) * 100
	MusicPlayer.play( 0 )
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$Control/AudioSettings/MC/VB/HB/OptionFullscreen.button_pressed = true
	Globals.on_fullscreen_mode_toggled.connect( on_fullscreen_mode_toggled )
	$Control/AudioSettings/MC/VB/HB/OptionLanguage.selected = Globals.language_id


func _on_settings_button_pressed() -> void:
	is_settings_mode = true
	swap_menus( audio_settings, settings, 0.25 )


func _on_ok_button_pressed() -> void:
	is_settings_mode = false
	swap_menus( settings, audio_settings, 0.25 )


func swap_menus( menu1: Control, menu2: Control, duration: float ) -> void:
	if is_fading:
		return
	is_fading = true
	menu1.modulate.a = 0
	menu1.show()
	var tween = create_tween()
	tween.set_parallel( true )
	tween.tween_property( menu2, "modulate:a", 0.0, duration )
	tween.tween_property( menu1, "modulate:a", 1.0, duration )
	await tween.finished
	menu2.hide()
	is_fading = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_sound_slider_value_changed( value: float ) -> void:
	if not is_settings_mode:
		return
	var pct = value / 100
	var db = linear_to_db( pct )
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index( "Sound" ), db )
	Globals.save_settings()
	$AudioStreamPlayer.play()


func _on_music_slider_value_changed( value: float ) -> void:
	var pct = value / 100
	var db = linear_to_db( pct )
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index( "Music" ), db )
	Globals.save_settings()


func _on_option_fullscreen_toggled( toggled_on: bool ) -> void:
	Globals.set_window_mode( toggled_on )
	Globals.save_settings()


func on_fullscreen_mode_toggled( is_fullscreen: bool ) -> void:
	$Control/AudioSettings/MC/VB/HB/OptionFullscreen.button_pressed = is_fullscreen


func _on_option_language_item_selected( index: int ) -> void:
	TranslationServer.set_locale( Globals.LANGUAGES[ index ] )
	Globals.language_id = index
	Globals.save_settings()
	Globals.on_language_changed.emit()
