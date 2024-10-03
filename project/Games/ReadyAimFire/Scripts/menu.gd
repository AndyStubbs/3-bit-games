extends Node


var bullet_index: int = -1
var is_loaded: bool = false


func _ready() -> void:
	Engine.physics_ticks_per_second = 60
	MusicPlayer.play( 1 )
	Globals.is_menu_page = true
	Globals.on_player_updated.connect( on_settings_updated )
	Raf.on_ammo_updated.connect( on_settings_updated )
	$Panel/MC/VB/HB2/Panel/MC/HB/ShotsNum.selected = roundi( float( Raf.shots ) / 3 ) - 1
	$Panel/MC/VB/HB2/Panel2/MC/HB/SizeSelect.selected = Raf.level_size
	$Panel/MC/VB/HB2/Panel4/MC/HB/TerrainSelect.selected = Raf.terrain_type
	$Panel/MC/VB/HB2/Panel3/MC/EasyTargeting.button_pressed = Raf.is_easy_targeting
	$Panel2/MC/HB/Panel/MC/VB/HB/MovementSelect.selected = roundi( Raf.movement_points / 5 )
	var item_list: ItemList = $Panel2/MC/HB/Panel/MC/VB/ItemList
	for i in Raf.bullet_data:
		var bullet_data = Raf.bullet_data[ i ]
		item_list.add_item( bullet_data.text, bullet_data.ui_image )
	update_ammo()
	await get_tree().create_timer( 0.15 ).timeout
	is_loaded = true


func _physics_process( _delta: float ) -> void:
	if is_loaded and Input.is_action_just_pressed( "Exit" ):
		get_tree().change_scene_to_packed( Globals.main_menu_scene )


func _on_easy_targeting_toggled( toggled_on: bool ) -> void:
	Raf.is_easy_targeting = toggled_on
	Raf.save_settings()


func _on_size_select_item_selected( index: int ) -> void:
	Raf.level_size = index
	Raf.save_settings()


func _on_terrain_select_item_selected( index: int ) -> void:
	Raf.terrain_type = index as Raf.TERRAIN
	Raf.save_settings()


func _on_start_button_pressed() -> void:
	Raf.is_tutorial = false
	await Raf.init_explosions( get_tree().physics_frame )
	get_tree().change_scene_to_packed( Raf.scenes.game )


func _on_tutorial_button_pressed() -> void:
	Raf.is_tutorial = true
	await Raf.init_explosions( get_tree().physics_frame )
	get_tree().change_scene_to_packed( Raf.scenes.game )


func _on_item_list_item_selected( index: int ) -> void:
	await get_tree().physics_frame
	if bullet_index != -1:
		update_raf()
	bullet_index = index
	setup()


func _on_close_button_pressed() -> void:
	if bullet_index != -1:
		update_raf()
	$Panel2.hide()
	$Panel.show()


func _on_settings_button_pressed() -> void:
	$Panel2.show()
	$Panel.hide()
	if not $Panel2/MC/HB/Panel/MC/VB/ItemList.is_anything_selected():
		$Panel2/MC/HB/Panel/MC/VB/ItemList.select( 0 )
		_on_item_list_item_selected( 0 )


func _on_reset_button_pressed() -> void:
	if bullet_index != -1:
		Raf.reset_bullet_data( bullet_index )
		setup()


func _on_reset_all_button_pressed() -> void:
	Raf.reset_all_bullet_data()
	setup()


func update_ammo() -> void:
	var ammo_grid = $Panel/MC/VB/MC/AmmoGrid
	for ammo_select in ammo_grid.get_children():
		if not ammo_select is RAF_AMMO_SELECT:
			continue
		if Raf.ammo.has( ammo_select.bullet_type ):
			ammo_select.is_selected = true
		else:
			ammo_select.is_selected = false
		ammo_select.init()


func setup() -> void:
	var freq: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB/BulletFreq
	var radius_input: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB8/ExpRadius
	var force_input: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB2/ExpForce
	var exp_scale_input: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB3/ExpScale
	var points: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB4/Points
	var color: ColorPickerButton = $Panel2/MC/HB/Panel2/MC/VB2/HB5/Color
	var bullet_scale: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB6/BulletScale
	setup_input( freq, "freq" )
	setup_input( radius_input, "radius" )
	setup_input( force_input, "force" )
	setup_input( exp_scale_input, "explosion_scale" )
	setup_input( points, "points" )
	setup_input( bullet_scale, "bullet_scale" )
	if Raf.bullet_data[ bullet_index ].has( "modulate" ):
		color.color = Raf.bullet_data[ bullet_index ].modulate
		color.disabled = false
		color.get_parent().modulate.a = 1.0
	else:
		color.color = Color.WHITE
		color.disabled = true
		color.get_parent().modulate.a = 0.5


func update_raf() -> void:
	var freq: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB/BulletFreq
	var radius_input: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB8/ExpRadius
	var force_input: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB2/ExpForce
	var exp_scale_input: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB3/ExpScale
	var points: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB4/Points
	var color: ColorPickerButton = $Panel2/MC/HB/Panel2/MC/VB2/HB5/Color
	var bullet_scale: OptionButton = $Panel2/MC/HB/Panel2/MC/VB2/HB6/BulletScale
	var bullet_data = Raf.bullet_data[ bullet_index ]
	update_input( freq, "freq" )
	update_input( radius_input, "radius" )
	update_input( force_input, "force" )
	update_input( exp_scale_input, "explosion_scale" )
	update_input( points, "points" )
	update_input( bullet_scale, "bullet_scale" )
	if bullet_data.has( "modulate" ):
		bullet_data.modulate = color.color
	Raf.save_settings()


func update_input( input: OptionButton, property: String ) -> void:
	var bullet_data = Raf.bullet_data[ bullet_index ]
	if bullet_data.has( property ) and input.selected < input.item_count:
		bullet_data[ property ] = float( input.get_item_text( input.selected ) )


func setup_input( input: OptionButton, property: String ) -> void:
	var bullet_data = Raf.bullet_data[ bullet_index ]
	if bullet_data.has( property ):
		for i in range( input.item_count ):
			var val = float( input.get_item_text( i ) )
			if val == bullet_data[ property ]:
				input.selected = i
				break
		input.disabled = false
		input.get_parent().modulate.a = 1
	else:
		input.selected = -1
		input.disabled = true
		input.get_parent().modulate.a = 0.5


func _on_controls_button_pressed() -> void:
	var controls: Panel = $Controls
	var tween: Tween = create_tween()
	var controls_button: Button = $Panel/MC/VB/HB3/ControlsButton
	controls.modulate.a = 0
	controls.show()
	tween.tween_property( controls, "modulate:a", 1.0, 0.5 )
	controls_button.release_focus()


func _on_clear_button_pressed() -> void:
	Raf.clear_ammo()
	update_ammo()


func _on_select_all_button_pressed() -> void:
	Raf.select_all_ammo()
	update_ammo()


func _on_shots_num_item_selected( index: int ) -> void:
	Raf.shots = ( index + 1 ) * 3
	Raf.save_settings()


func on_settings_updated() -> void:
	if Raf.ammo.size() == 0:
		$Panel/MC/VB/HB3/StartButton.disabled = true
		$Panel/MC/VB/HB3/StartButton.tooltip_text = tr( "TR_TOOLTIP_BULLET_1" )
	else:
		var player_count: int = 0
		for player in Globals.players:
			if player.enabled:
				player_count += 1
		if player_count < 2:
			$Panel/MC/VB/HB3/StartButton.disabled = true
			$Panel/MC/VB/HB3/StartButton.tooltip_text = tr( "TR_TOOLTIP_2_PLAYERS" )
		else:
			$Panel/MC/VB/HB3/StartButton.disabled = false


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed( Globals.main_menu_scene )


func _on_option_button_item_selected( index: int ) -> void:
	Raf.movement_points = index * 5
