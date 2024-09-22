extends Node
class_name RAF_Game


const TANK_SCENE = preload( "res://Games/ReadyAimFire/Scenes/tank.tscn" )
const WIND_SCENE = preload( "res://Games/ReadyAimFire/Scenes/wind.tscn" )
const MENU_SCENE = preload( "res://Games/ReadyAimFire/Scenes/menu.tscn" )
const MAX_WIND: float = 400
const MIN_WIND: float = -400


var level: RAF_Level
var tanks: Array
var tank_turn: int = 0
var width: int = 480
var height: int = 270
var camera_target: Node2D
var tut_step: int = 0
var tween_options: Tween


@onready var ground: RAF_Ground = $Ground
@onready var scores_hb: HBoxContainer = $CanvasLayer/Players/HB
@onready var outline: Panel = $CanvasLayer/Players/Outline
@onready var camera: Camera2D = $World/Camera2D
@onready var world: Node2D = $World


func _ready() -> void:
	Globals.is_menu_page = false
	# Set the default gravity direction to `Vector2(0, 1)`.
	PhysicsServer2D.area_set_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		Vector2.DOWN
	)
	start_game()
	if Raf.is_tutorial:
		$CanvasLayer/Options/MC/HB/ResetButton.show()
		start_tutorial()
		$CanvasLayer/Options.modulate.a = 1.0
	else:
		Globals.on_cursor_mode_toggled.connect( on_cursor_mode_toggled )


func _process( _delta: float ) -> void:
	if Input.is_action_pressed( "Exit" ):
		get_tree().change_scene_to_packed( Raf.scenes.menu )


func _physics_process( delta: float ) -> void:
	
	# Random generate wind particle
	if randf_range( 0, 1 ) < 0.15:
		create_wind( -10 )
	
	# Move camera towards target
	if camera_target != null:
		camera.position = camera.position.move_toward( camera_target.position, delta * 1300 )


func start_game() -> void:
	if Raf.is_tutorial:
		width = Raf.SIZES[ 0 ]
	else:
		width = Raf.SIZES[ Raf.level_size ]
	init_level()
	camera.limit_right = roundi( float( width ) * float( level.scale ) )
	camera.limit_bottom = roundi( float( height ) * float( level.scale ) )
	ground.init( level )
	init_tanks()


func start_tutorial() -> void:
	$CanvasLayer/Options/MC/HB/ResetButton.show()
	var tut = $CanvasLayer/Tutorial
	tut.modulate.a = 0
	tut.show()
	await show_tutorial_text( 0, 1 )


func show_tutorial_text( step, duration ) -> void:
	$CanvasLayer/Tutorial/MC/VB/HB/PreviousButton.disabled = true
	$CanvasLayer/Tutorial/MC/VB/HB/NextButton.disabled = true
	var tut: Panel = $CanvasLayer/Tutorial
	var tween2 = create_tween()
	tween2.tween_property( tut, "modulate:a", 0.0, duration / 2 )
	await tween2.finished
	var msg: String = ""
	for line in Raf.TUTORIAL_TEXT[ step ]:
		msg += tr( line ) + "\n"
	$CanvasLayer/Tutorial/MC/VB/Text.text = msg
	tut.size.y = Raf.TUTORIAL_TEXT[ step ].size() * 36 + 100
	var tween = create_tween()
	tween.tween_property( tut, "modulate:a", 1.0, duration / 2 )
	await tween.finished
	if step > 0:
		$CanvasLayer/Tutorial/MC/VB/HB/PreviousButton.disabled = false
	if step < Raf.TUTORIAL_TEXT.size() - 1:
		$CanvasLayer/Tutorial/MC/VB/HB/NextButton.disabled = false


func init_level() -> void:
	level = RAF_Level.new()
	level.on_turn_ended.connect( on_turn_ended )
	level.on_bullet_spawned.connect( on_bullet_spawned )
	level.on_bullet_destroyed.connect( on_bullet_destroyed )
	level.width = width
	level.height = height
	level.heights = []
	level.tanks = []
	tanks = level.tanks
	init_bullets()
	init_wind()
	var data: Dictionary = {}
	data[ "max_dirt" ] = roundi( level.height * 0.8 )
	data[ "min_dirt" ] = roundi( level.height * 0.21 )
	data[ "max_rock" ] = level.height - 10
	data[ "min_rock" ] = data[ "max_dirt" ] - 10
	data[ "start_dirt" ] = level.height - roundi( float( level.height ) / 4 )
	data[ "start_rock" ] = (
		data[ "min_rock" ] + roundi( float( data[ "max_rock" ] - data[ "min_rock" ] ) / 2 )
	)
	
	var data_type: Raf.TERRAIN
	if Raf.is_tutorial:
		data_type = Raf.TERRAIN.FLAT
	else:
		if Raf.terrain_type == Raf.TERRAIN.ANY:
			var data_types: Array = [
				Raf.TERRAIN.MOUNTAIN, Raf.TERRAIN.MOUNTAIN, Raf.TERRAIN.MOUNTAIN,
				Raf.TERRAIN.VALLEY, Raf.TERRAIN.VALLEY,
				Raf.TERRAIN.RANDOM1,Raf.TERRAIN.RANDOM1,
				Raf.TERRAIN.RANDOM2
			]
			data_type = data_types.pick_random()
		else:
			data_type = Raf.terrain_type
	if data_type == Raf.TERRAIN.MOUNTAIN:
		create_mountain_heights( data )
	elif data_type == Raf.TERRAIN.VALLEY:
		create_valley_heights( data )
	elif data_type == Raf.TERRAIN.RANDOM1:
		create_random_heights( data )
	elif data_type == Raf.TERRAIN.RANDOM2:
		create_random_segments( data )
	elif data_type == Raf.TERRAIN.FLAT:
		create_flat_heights( data )


func create_mountain_heights( data: Dictionary ) -> void:
	data[ "start_dirt" ] = level.height - roundi( float( level.height ) / 4 )
	data[ "segments" ] = [
		[ [ -2, 1 ], [ -1, 1 ] ],
		[ [ -6, 1 ], [ -3, 1 ] ],
		[ [ -1, 1 ], [ -1, 1 ] ],
		[ [ -1, 6 ], [ -1, 3 ] ],
		[ [ -1, 2 ], [ -1, 1 ] ],
	]
	create_segment_heights( data )


func create_valley_heights( data: Dictionary ) -> void:
	data[ "start_dirt" ] = roundi( float( level.height ) * 0.35 )
	data[ "segments" ] = [
		[ [ -1, 2 ], [ -1, 1 ] ],
		[ [ -1, 5 ], [ -1, 3 ] ],
		[ [ -1, 1 ], [ -1, 1 ] ],
		[ [ -5, 1 ], [ -3, 1 ] ],
		[ [ -1, 2 ], [ -1, 1 ] ],
	]
	create_segment_heights( data )


func create_random_heights( data: Dictionary ) -> void:
	data[ "start_dirt" ] = roundi( float( level.height ) * 0.57 )
	data[ "segments" ] = [
		[ [ -1, 1 ], [ -1, 1 ] ],
		[ [ -1, 1 ], [ -1, 1 ] ],
		[ [ -1, 1 ], [ -1, 1 ] ],
		[ [ -1, 1 ], [ -1, 1 ] ],
		[ [ -1, 1 ], [ -1, 1 ] ],
	]
	create_segment_heights( data )


func create_flat_heights( data: Dictionary ) -> void:
	data[ "start_dirt" ] = roundi( float( level.height ) * 0.57 )
	data[ "segments" ] = [
		[ [ 0, 0 ], [ 0, 0 ] ]
	]
	create_segment_heights( data )


func create_random_segments( data: Dictionary ) -> void:
	data[ "start_dirt" ] = roundi( float( level.height ) * 0.57 )
	var segment_count: int
	if width == Raf.SIZES[ 0 ]:
		segment_count = randi_range( 2, 6 )
	elif width == Raf.SIZES[ 1 ]:
		segment_count = randi_range( 3, 7 )
	else:
		segment_count = randi_range( 4, 10 )
	data[ "segments" ] = []
	for i in range( segment_count ):
		data[ "segments" ].append( [ [ randi_range( -3, -1 ), randi_range( 1, 3 ) ], [ -1, 1 ] ] )
	create_segment_heights( data )


func create_segment_heights( data: Dictionary ) -> void:
	var max_dirt = data.max_dirt
	var min_dirt = data.min_dirt
	var max_rock = data.max_rock
	var min_rock = data.min_rock
	var dirt_height = data.start_dirt
	var rock_height = data.start_rock
	
	for x in range( level.width ):
		if dirt_height < rock_height:
			level.heights.append( dirt_height )
		else:
			level.heights.append( rock_height )
		level.rock_heights.append( rock_height )
		var i = floori( ( x / float( level.width ) ) * data.segments.size() )
		var dirt_segment = data.segments[ i ][ 0 ]
		var rock_segment = data.segments[ i ][ 1 ]
		var dy = clampi( randi_range( dirt_segment[ 0 ], dirt_segment[ 1 ] ), -1, 1 )
		var ry = clampi( randi_range( rock_segment[ 0 ], rock_segment[ 1 ] ), -1, 1 )
		dirt_height = clampi( dirt_height + dy, min_dirt, max_dirt )
		rock_height = clampi( rock_height + ry, min_rock, max_rock )


func init_bullets() -> void:
	if Raf.is_tutorial:
		level.ammo.append_array( Raf.ammo_all )
		return
	var bucket: Array = []
	for bullet_type in Raf.ammo:
		var bullet_data = Raf.bullet_data[ bullet_type ]
		for i in range( bullet_data.freq ):
			bucket.append( bullet_type )
	var count: int = Raf.shots
	while count > 0:
		level.ammo.append( bucket.pick_random() )
		count -= 1


func init_wind() -> void:
	if Raf.is_tutorial:
		level.wind.x = 0
	else:
		# 30% chance of having a big wind range
		#if randf_range( 0, 1 ) > 0.99:
		if randf_range( 0, 1 ) > 0.3:
			level.wind.x = randf_range( MIN_WIND / 3, MAX_WIND / 3 )
		else:
			level.wind.x = randf_range( MIN_WIND, MAX_WIND )
	for i in range( 50 ):
		create_wind( randf_range( -10, level.height * level.scale ) )


func init_tanks() -> void:
	if Raf.is_tutorial:
		var tank = TANK_SCENE.instantiate()
		tank.player_id = 0
		tank.colors = Globals.PLAYER_COLORS[ 0 ]
		tank.controls = "ANY"
		tank.display_name = tr( "TR_YOU" )
		tank.is_facing_left = false
		tank.movement_points = 10
		tanks.append( tank )
		$World.add_child( tank )
		var tank2 = TANK_SCENE.instantiate()
		tank2.player_id = 1
		tank2.colors = Globals.PLAYER_COLORS[ 1 ]
		tank2.controls = "ANY"
		tank2.display_name = tr( "TR_CPU" )
		tank2.is_facing_left = true
		tanks.append( tank2 )
		$World.add_child( tank2 )
	else:
		var is_left = false
		var player_id: int = 0
		for player in Globals.players:
			if player.enabled:
				var tank = TANK_SCENE.instantiate()
				tank.player_id = player_id
				tank.colors = Globals.PLAYER_COLORS[ player.colors ]
				tank.controls = player.controls
				if player.name_changed:
					tank.display_name = player.name
				else:
					tank.display_name = tr( player.name )
				tank.is_facing_left = is_left
				tank.movement_points = Raf.movement_points
				is_left = !is_left
				tanks.append( tank )
				$World.add_child( tank )
				player_id += 1
	if tanks.size() == 1:
		tanks[ 0 ].position.x = ( width * level.scale ) / 2
	elif tanks.size() == 2:
		tanks[ 0 ].position.x = 150
		tanks[ 1 ].position.x = ( width * level.scale ) - 150
	elif tanks.size() == 3:
		tanks[ 0 ].position.x = 150
		tanks[ 1 ].position.x = ( width * level.scale ) / 2
		tanks[ 2 ].position.x = ( width * level.scale ) - 150
		tanks[ 2 ].is_facing_left = true
	elif tanks.size() == 4:
		tanks[ 0 ].position.x = 150
		tanks[ 1 ].position.x = 150 + ( width * level.scale ) / 4
		tanks[ 2 ].position.x = ( width * level.scale ) - 150 - ( width * level.scale ) / 4
		tanks[ 3 ].position.x = ( width * level.scale ) - 150
	
	var total_size = 0
	for i in range( tanks.size() ):
		scores_hb.get_child( i ).show()
		
		# Update Player Label
		var display_name: String = tanks[ i ].display_name
		var player_label: Label = scores_hb.get_child( i ).get_child( 0 )
		var size = clampf( display_name.length() * 26, 300, 900 )
		total_size += size
		player_label.text = display_name
		player_label.size.x = size
		player_label.label_settings.font_color = tanks[ i ].colors[ 1 ]
		player_label.label_settings.outline_color = tanks[ i ].colors[ 2 ]
		
		# Update Player Control
		var control: Control = player_label.get_parent()
		control.custom_minimum_size.x =  player_label.size.x
		control.size.x = player_label.size.x
		
		# Link score label to player
		var score_label: Label = scores_hb.get_child( i ).get_child( 1 )
		tanks[ i ].init( level, score_label )
	
	if total_size > 1600:
		scores_hb.add_theme_constant_override( "separation", 15 )
	elif total_size > 1500:
		scores_hb.add_theme_constant_override( "separation", 30 )
	elif total_size > 1400:
		scores_hb.add_theme_constant_override( "separation", 60 )
	
	if Raf.is_tutorial:
		tank_turn = 1
	else:
		tank_turn = randi_range( 0, tanks.size() - 1 )
	next_turn()


func next_turn( delay: float = 0 ) -> void:
	if Raf.is_tutorial:
		tank_turn = 1
	tank_turn += 1
	if tank_turn >= tanks.size():
		tank_turn = 0
	var tank: RAF_Tank = tanks[ tank_turn ]
	if tank.bullet_select.item_count == 0:
		end_game()
		return
	$NextTurnSound.play()
	outline.get_parent().remove_child( outline )
	tank.score_label.get_parent().add_child( outline )
	outline.position = Vector2.ZERO
	outline.size.x = tank.score_label.get_parent().size.x
	outline.show()
	camera_target = tank
	await get_tree().create_timer( delay ).timeout
	tank.begin_turn()


func create_wind( y: float ) -> void:
	var size = level.width * level.scale
	var wind = WIND_SCENE.instantiate()
	wind.init( level )
	add_child( wind )
	wind.position = Vector2( randf_range( -size, size * 2 ), y )


func on_turn_ended( delay: float ) -> void:
	tanks[ tank_turn ].hide_ui()
	await get_tree().create_timer( delay / 2 ).timeout
	next_turn( delay / 2 )


func on_bullet_spawned( bullet: Node2D ) -> void:
	camera_target = bullet


func on_bullet_destroyed() -> void:
	camera_target = null


func end_game() -> void:
	Globals.is_menu_page = true
	while level.points_tracker.size() > 0:
		await get_tree().physics_frame
	
	$CanvasLayer/Players.hide()
	$GameoverSound2.play()
	var game_over = $CanvasLayer/GameOver
	
	var scoreboards = [
		{ "hb": $CanvasLayer/GameOver/MC/VB/HB, "score": 0 },
		{ "hb": $CanvasLayer/GameOver/MC/VB/HB2, "score": 0 },
		{ "hb": $CanvasLayer/GameOver/MC/VB/HB3, "score": 0 },
		{ "hb": $CanvasLayer/GameOver/MC/VB/HB4, "score": 0 },
	]
	
	for i in range( tanks.size() ):
		scoreboards[ i ].hb.show()
		scoreboards[ i ].hb.get_child( 0 ).modulate = tanks[ i ].colors[ 1 ]
		scoreboards[ i ].hb.get_child( 0 ).text = "%-16s" % tanks[ i ].display_name
		scoreboards[ i ].hb.get_child( 1 ).text = "%5d" % 0
	
	game_over.modulate.a = 0
	game_over.show()
	var tween = create_tween()
	tween.tween_property( game_over, "modulate:a", 1.0, 2.0 )
	await tween.finished
	
	$TickSound.play()
	var increment: int = clampi( roundi( float( level.scores.size() ) / 4 ), 8, 50 )
	for score in level.scores:
		var score_id = score[ 0 ]
		var score_points = score[ 1 ]
		var score_label: Label = scoreboards[ score_id ].hb.get_child( 1 )
		var current_score = score_points
		var scoreboard_score = scoreboards[ score_id ].score
		await add_to_scoreboard( score_label, scoreboard_score, current_score, increment )
		scoreboards[ score_id ].score = scoreboard_score + score_points
	$TickSound.stop()
	
	await get_tree().create_timer( 1.5 ).timeout
	
	$GameoverSound.play()
	var max_score: int = -9999999
	var winners: Array = [ 0 ]
	for i in range( tanks.size() ):
		if scoreboards[ i ].score == max_score:
			winners.append( i )
		elif scoreboards[ i ].score > max_score:
			max_score = scoreboards[ i ].score
			winners = [ i ]
	
	var winners_vb: VBoxContainer = $CanvasLayer/GameOver/MC/VB/Winners
	winners_vb.get_child( 0 ).hide()
	winners_vb.get_child( 1 ).hide()
	winners_vb.get_child( 2 ).hide()
	winners_vb.get_child( 3 ).hide()
	var colors = [ Color.WHITE, Color.DIM_GRAY ]
	for i in winners:
		var label: Label = winners_vb.get_child( i )
		label.text = tanks[ i ].display_name
		label.label_settings.font_color = tanks[ i ].colors[ 1 ]
		label.label_settings.outline_color = tanks[ i ].colors[ 2 ]
		label.modulate.a = 0
		label.show()
		var l_tween = create_tween()
		l_tween.tween_property( label, "modulate:a", 1.0, 1.0 )
	if winners.size() > 3:
		$CanvasLayer/GameOver/MC/VB/Control2.hide()
		$CanvasLayer/GameOver/MC/VB/Control3.hide()
		$CanvasLayer/GameOver/MC/VB/Control3b.hide()
		$CanvasLayer/GameOver/MC/VB/Control4.hide()
		$CanvasLayer/GameOver/MC/VB/Control4b.hide()
	elif winners.size() > 2:
		$CanvasLayer/GameOver/MC/VB/Control3.hide()
		$CanvasLayer/GameOver/MC/VB/Control3b.hide()
		$CanvasLayer/GameOver/MC/VB/Control4.hide()
		$CanvasLayer/GameOver/MC/VB/Control4b.hide()
	elif winners.size() > 1:
		$CanvasLayer/GameOver/MC/VB/Control3.hide()
		$CanvasLayer/GameOver/MC/VB/Control4.hide()
	var tween3 = create_tween()
	tween3.tween_property( winners_vb, "modulate:a", 1.0, 1.0 )


func add_to_scoreboard( label: Label, start_score: int, score: int, increment: int ) -> void:
	for i: float in range( 1, 100 + increment, increment ):
		var pct: float = clampf( i / 100, 0, 1 )
		var current_score = ( start_score + ( score * pct ) )
		label.text = "%5d" % current_score
		if current_score < 0:
			label.modulate = Color.RED
		else:
			label.modulate = Color.WHITE
		await get_tree().physics_frame


func on_cursor_mode_toggled() -> void:
	if Globals.is_cursor_mode:
		$CanvasLayer/Options.modulate.a = 1
	else:
		$CanvasLayer/Options.modulate.a = 0


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_packed( Raf.scenes.menu )


func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed( Raf.scenes.menu )


func _on_controls_button_pressed() -> void:
	var controls: Panel = $CanvasLayer/Controls
	var tween: Tween = create_tween()
	var controls_button: Button = $CanvasLayer/Options/MC/HB/ControlsButton
	controls.modulate.a = 0
	controls.show()
	tween.tween_property( controls, "modulate:a", 1.0, 0.5 )
	controls_button.release_focus()
	Raf.is_paused = true
	AudioServer.set_bus_mute( AudioServer.get_bus_index( "Sound" ), true )


func _on_previous_button_pressed() -> void:
	tut_step = clampi( tut_step - 1, 0, Raf.TUTORIAL_TEXT.size() )
	show_tutorial_text( tut_step, 1 )


func _on_next_button_pressed() -> void:
	tut_step = clampi( tut_step + 1, 0, Raf.TUTORIAL_TEXT.size() )
	show_tutorial_text( tut_step, 1 )


func _on_options_mouse_entered() -> void:
	if Raf.is_tutorial or Globals.is_cursor_mode:
		return
	if tween_options and tween_options.is_running():
		tween_options.stop()
	tween_options = create_tween()
	tween_options.tween_property( $CanvasLayer/Options, "modulate:a", 1.0, 1.0 )


func _on_options_mouse_exited() -> void:
	if Raf.is_tutorial or Globals.is_cursor_mode:
		return
	if tween_options and tween_options.is_running():
		tween_options.stop()
	tween_options = create_tween()
	tween_options.tween_property( $CanvasLayer/Options, "modulate:a", 0.0, 1.0 )
