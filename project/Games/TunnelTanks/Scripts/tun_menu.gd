extends Node


var is_loaded: bool = false


@onready var opt_speed: OptionButton = $MC/VB/MC/Panel/MC/VB/HB2/Panel/MC/VB/SpeedOptions
@onready var opt_maps: OptionButton = $MC/VB/MC/Panel/MC/VB/HB2/Panel2/MC/VB/MapSizeOptions
@onready var opt_rocks: OptionButton = $MC/VB/MC/Panel/MC/VB/HB2/Panel3/MC/VB/RocksOptions
@onready var opt_points: OptionButton = $MC/VB/MC/Panel/MC/VB/HB2/Panel4/MC/VB/PointsOptions
@onready var opt_cpus: OptionButton = $MC/VB/MC/Panel/MC/VB/HB2/Panel5/MC/VB/AddCPUOptions


func update_settings() -> void:
	Tun.settings.SPEED = opt_speed.get_selected_id()
	Tun.settings.SIZE = opt_maps.get_selected_id()
	Tun.settings.ROCKS = opt_rocks.get_selected_id()
	Tun.settings.ADD_CPUS = opt_cpus.get_selected_id()
	Tun.settings.SCORE = opt_points.get_selected_id()
	Tun.save_settings()
	update_button_status()


func on_player_updated() -> void:
	update_button_status()


func update_button_status() -> void:
	var player_count: int = 0
	var cpu_count: int = 0
	for player in Globals.players:
		if player.enabled:
			if player.controls == "CPU":
				cpu_count += 1
			else:
				player_count += 1
	var start_button: Button = $MC/VB/MC/Panel/MC/VB/HB3/StartButton
	var total_players = player_count + cpu_count + Tun.settings.ADD_CPUS
	var max_players = Tun.MAX_PLAYERS[ Tun.settings.SIZE ]
	if total_players < 1:
		start_button.tooltip_text = tr( "TR_TOOLTIP_1_PLAYER" )
		start_button.disabled = true
	elif total_players >= max_players:
		start_button.tooltip_text = tr( "TR_TOOLTIP_MAX_PLAYERS" )
		start_button.disabled = true
	else:
		start_button.tooltip_text = ""
		start_button.disabled = false


func _ready() -> void:
	MusicPlayer.play( 2 )
	Engine.physics_ticks_per_second = 60
	Globals.on_player_updated.connect( on_player_updated )
	opt_speed.select( Tun.settings.SPEED )
	opt_maps.select( Tun.settings.SIZE )
	opt_rocks.select( Tun.settings.ROCKS )
	opt_points.select( Tun.settings.SCORE )
	opt_cpus.select( Tun.settings.ADD_CPUS )
	update_button_status()
	await get_tree().create_timer( 0.15 ).timeout
	is_loaded = true


func _process( _delta: float ) -> void:
	if is_loaded and Input.is_action_just_pressed( "Exit" ):
		get_tree().change_scene_to_packed( Globals.main_menu_scene )


func _on_back_button_pressed() -> void:
	update_settings()
	get_tree().change_scene_to_packed( Globals.main_menu_scene )


func _on_start_button_pressed() -> void:
	update_settings()
	get_tree().change_scene_to_packed( Tun.scenes.game )


func _on_option_updated( _index: int ) -> void:
	update_settings()


func _on_show_controls_pressed() -> void:
	var controls: Panel = $Controls
	var tween: Tween = create_tween()
	var controls_button: Button = $MC/VB/MC/Panel/MC/VB/HB3/ControlsButton
	controls.modulate.a = 0
	controls.show()
	tween.tween_property( controls, "modulate:a", 1.0, 0.5 )
	controls_button.release_focus()
