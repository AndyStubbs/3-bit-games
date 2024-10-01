extends Node


const PIXEL_SCENE = preload( "res://Games/TunnelTanks/Scenes/tun_pixel.tscn" )
const PLAYERS_ZERO = preload( "res://Games/TunnelTanks/Scenes/tun_players_zero.tscn" )
const PLAYERS_ONE = preload( "res://Games/TunnelTanks/Scenes/tun_players_one.tscn" )
const PLAYERS_TWO = preload( "res://Games/TunnelTanks/Scenes/tun_players_two.tscn" )
const PLAYERS_THREE = preload( "res://Games/TunnelTanks/Scenes/tun_players_three.tscn" )
const PLAYERS_FOUR = preload( "res://Games/TunnelTanks/Scenes/tun_players_four.tscn" )
const TANK_SCENE = preload( "res://Games/TunnelTanks/Scenes/tun_tank.tscn" )


var ground: TUN_Ground
var backgrounds: Array = []
var tank_lookup: Dictionary
var all_tanks: Array = []
var tanks: Array = []
var dead_tanks: Array = []
var bases: Array = []
var img_needs_update: bool = false
var sounds: Dictionary
var is_game_ready: bool = false
var is_waiting_for_bullets_to_end: bool = false
var wait_time_end: float = 0
var winner: TUN_Tank
var round_num: int = 0


func _enter_tree() -> void:
	Tun.game_data.tanks = tanks
	Tun.on_sprite_ready.connect( on_sprite_ready )
	Tun.on_tank_ready.connect( on_tank_ready )
	Tun.on_tank_moved.connect( on_tank_moved )
	Tun.on_bullet_fired.connect( on_bullet_fired )
	Tun.on_bullet_moved.connect( on_bullet_moved )
	Tun.on_pixel_moved.connect( on_pixel_moved )
	Tun.on_tank_destroyed.connect( on_tank_destroyed )
	Tun.on_grid_path_generated.connect( on_grid_path_generated )
	ground = $TunGround
	var width = Tun.SIZES[ Tun.settings.SIZE ][ 1 ]
	var height = Tun.SIZES[ Tun.settings.SIZE ][ 2 ]
	ground.init( width, height )


func _ready() -> void:
	Globals.is_menu_page = false
	if Tun.settings.SPEED == 0:
		Engine.physics_ticks_per_second = 30
	elif Tun.settings.SPEED == 1:
		Engine.physics_ticks_per_second = 60
	else:
		Engine.physics_ticks_per_second = 90
	await get_tree().create_timer( 1.0 ).timeout
	var players_container: Node
	var players: Array = []
	var cpus: Array = []
	for player in Globals.players:
		if player.enabled:
			if player.controls == "CPU":
				cpus.append( player )
			else:
				players.append( player )
	var tank_nodes: Array = []
	if players.size() == 0:
		players_container = PLAYERS_ZERO.instantiate()
		tank_nodes.append(
			"MC/HB/TunPlayerContainer/View/SubViewportContainer/SubViewport/World/Tank"
		)
	if players.size() == 1:
		players_container = PLAYERS_ONE.instantiate()
		tank_nodes.append(
			"MC/HB/TunPlayerContainer/View/SubViewportContainer/SubViewport/World/Tank"
		)
	elif players.size() == 2:
		players_container = PLAYERS_TWO.instantiate()
		tank_nodes.append(
			"MC/HB/TunPlayerContainer/View/SubViewportContainer/SubViewport/World/Tank"
		)
		tank_nodes.append(
			"MC/HB/TunPlayerContainer2/View/SubViewportContainer/SubViewport/World/Tank"
		)
	elif players.size() == 3:
		players_container = PLAYERS_THREE.instantiate()
		tank_nodes.append(
			"MC/HB/TunPlayerContainer/View/SubViewportContainer/SubViewport/World/Tank"
		)
		tank_nodes.append(
			"MC/HB/TunPlayerContainer2/View/SubViewportContainer/SubViewport/World/Tank"
		)
		tank_nodes.append(
			"MC/HB/TunPlayerContainer3/View/SubViewportContainer/SubViewport/World/Tank"
		)
	elif players.size() == 4:
		tank_nodes.append(
			"MC/VB/HB/TunPlayerContainer/View/SubViewportContainer/SubViewport/World/Tank"
		)
		tank_nodes.append(
			"MC/VB/HB/TunPlayerContainer2/View/SubViewportContainer/SubViewport/World/Tank"
		)
		tank_nodes.append(
			"MC/VB/HB2/TunPlayerContainer/View/SubViewportContainer/SubViewport/World/Tank"
		)
		tank_nodes.append(
			"MC/VB/HB2/TunPlayerContainer2/View/SubViewportContainer/SubViewport/World/Tank"
		)
		players_container = PLAYERS_FOUR.instantiate()
	if players.size() == 0:
		var node_text: String = tank_nodes[ 0 ]
		var tank: TUN_Tank = players_container.get_node( node_text )
		tank.position = Vector2( float( ground.width ) / 2, float( ground.height ) / 2 )
		tank.map_width = ground.width
		tank.map_height = ground.height
		tank.last_pos = tank.position
		tank.is_blank = true
		tank.init()
	for i in range( players.size() ):
		var node_text: String = tank_nodes[ i ]
		var tank: TUN_Tank = players_container.get_node( node_text )
		set_tank_data( tank, players[ i ] )
	
	# Add additional cpus
	for i in range( Tun.settings.ADD_CPUS ):
		cpus.append( {
			"id": 4 + i,
			"enabled": true,
			"name": "CPU %s" % i,
			"controls": "CPU",
			"colors": randi_range( 0, Globals.PLAYER_COLORS.size() - 1 ),
			"name_changed": true
		} )
	for cpu in cpus:
		var tank: TUN_Tank = TANK_SCENE.instantiate()
		set_tank_data( tank, cpu )
		tank.is_cpu = true
		$PlayersCPU/SubViewport/World.add_child( tank )
		tank.init()
	$Players.add_child( players_container )
	sounds = {
		"LaserHit": $Sounds/LaserHit,
		"LaserFire": $Sounds/LaserFire,
		"TankExploded": $Sounds/TankExploded,
		"TankHit": $Sounds/TankHit,
		"TankCollided": $Sounds/TankCollided,
	}
	RenderingServer.set_default_clear_color( ground.ROCK_COLOR )
	init_level()
	var tween = create_tween()
	tween.tween_property( $LoadingScreen, "modulate:a", 0.0, 1.0 )
	await tween.finished
	$LoadingScreen.hide()


func _process( _delta: float ) -> void:
	if not is_game_ready:
		begin_game_if_ready()
	
	if is_waiting_for_bullets_to_end:
		if Tun.bullet_count == 0 or Time.get_ticks_msec() > wait_time_end:
			is_waiting_for_bullets_to_end = false
			end_round()
	if Input.is_action_just_pressed( "Exit" ):
		Tun.ground = null
		get_tree().change_scene_to_packed( Tun.scenes.menu )
	
	if img_needs_update:
		ground.update()
		img_needs_update = false


func set_tank_data( tank: TUN_Tank, player_data: Dictionary ) -> void:
	var colors = Globals.PLAYER_COLORS[ player_data.colors ]
	if player_data.name_changed:
		tank.display_name = player_data.name
	else:
		tank.display_name = tr( player_data.name )
	tank.player_id = player_data.id
	tank.map_width = ground.width
	tank.map_height = ground.height
	tank.color1 = colors[ 1 ].darkened( 0.25 )
	tank.color2 = colors[ 1 ]
	tank.color3 = colors[ 1 ].lightened( 0.25 )
	tank.controls = player_data.controls


func begin_game_if_ready() -> void:
	var is_ready: bool = true
	if is_ready:
		begin_game()


func on_sprite_ready( sprite: Sprite2D, sprite_type: Tun.SPRITE_TYPES ) -> void:
	if sprite_type == Tun.SPRITE_TYPES.ZERO:
		sprite.offset.x = -float( ground.width * 2 ) / 4.0
		sprite.offset.y = -float( ground.height * 2 ) / 4.0
		sprite.texture = ground.img_texture_zero
	elif sprite_type == Tun.SPRITE_TYPES.BACKGROUND:
		backgrounds.append( sprite )
		sprite.texture = ground.img_texture
	elif sprite_type == Tun.SPRITE_TYPES.MINIMAP:
		sprite.texture = ground.img_texture
	elif sprite_type == Tun.SPRITE_TYPES.MINIMAP_B:
		sprite.texture = ground.img_texture_zero


func on_tank_ready( tank: TUN_Tank ) -> void:
	ground.base_colors.append( tank.color1 )
	all_tanks.append( tank )
	tanks.append( tank )
	tank_lookup[ tank.network_id ] = tank
	get_new_base()


func get_new_base() -> Rect2i:
	var base_rect: Rect2i
	var is_picked: bool = false
	var base_count: int = bases.size()
	var tries: int = 0
	while not is_picked:
		tries += 1
		
		# Reset all bases if can't find a good fit
		if tries > 100:
			bases = []
			for i in range( base_count ):
				get_new_base()
			tries = 0
		
		# Place current tank's base
		base_rect = ground.get_random_base_rect()
		var outer_rect = embiggen_rect( base_rect )
		is_picked = true
		for placed_base: Rect2i in bases:
			var outer_placed = embiggen_rect( placed_base )
			if outer_placed.intersects( outer_rect ):
				is_picked = false
	
	bases.append( base_rect )
	return base_rect


func embiggen_rect( rect: Rect2i ) -> Rect2i:
	var outer_rect = Rect2i( rect )
	outer_rect.position.x -= 20
	outer_rect.position.y -= 20
	outer_rect.size.x += 40
	outer_rect.size.y += 40
	return outer_rect


func init_level() -> void:
	for i in range( tanks.size() ):
		var tank: TUN_Tank = tanks[ i ]
		tank.bases = bases
		tank.base = bases[ i ]
		create_clones( tank )
		reset_tank_position( tank )
	ground.draw_level( bases, tanks )
	ground.setup_grid()
	begin_game()


func create_clones( node ) -> void:
	for background in backgrounds:
		if node.get_parent() != background:
			background.add_child( node.create_clone() )


func reset_tank_position( tank: TUN_Tank ) -> void:
	@warning_ignore( "integer_division" )
	tank.position = Vector2(
		roundf( tank.base.position.x - 4 + ground.BASE_DATA.width / 2 ),
		roundf( tank.base.position.y - 4 + ground.BASE_DATA.height / 2 )
	)


func begin_game() -> void:
	is_game_ready = true
	for tank: TUN_Tank in tanks:
		tank.set_process( true )
		tank.set_physics_process( true )


func on_tank_moved( tank: TUN_Tank ) -> void:
	if tank.position.is_equal_approx( tank.last_pos ):
		return
	if check_tanks_collision( tank ):
		tank.position = tank.last_pos
		tank.blocked_count += 1
		return
	if not check_area( Tun.tank_data[ "collision_" + tank.direction ], tank.position ):
		var is_dug: bool = dig_area( Tun.tank_data[ "dig_" + tank.direction ], tank.position )
		img_needs_update = true
		if is_dug:
			var distance = floori( tank.position.distance_to( tank.last_pos ) )
			tank.meters_dug += distance
		tank.position = tank.last_pos
		tank.delay_count = 3
		tank.blocked_count += 1
	else:
		tank.blocked_count = 0
		var distance = floori( tank.position.distance_to( tank.last_pos ) )
		tank.meters_moved += distance


func check_tanks_collision( tank: TUN_Tank ) -> bool:
	var data = Tun.tank_data[ "collision_" + tank.direction ]
	for y in range( data.size() ):
		for x in range( data[ y ].size() ):
			if data[ y ][ x ] == 1:
				var pos: Vector2i = Vector2i(
					int( tank.position.x + x ), int( tank.position.y + y )
				)
				if get_tank_collision( pos, tank ) != null:
					return true
	return false


func check_area( data: Array, pos: Vector2i ) -> bool:
	for y in range( data.size() ):
		for x in range( data[ y ].size() ):
			if data[ y ][ x ] == 1:
				var color = ground.img.get_pixel( pos.x + x, pos.y + y )
				if color != Color.BLACK:
					return false
	return true


func dig_area( data: Array, pos: Vector2 ) -> bool:
	var pixels_dug: Array = []
	var is_dug: bool = false
	for y in range( data.size() ):
		for x in range( data[ y ].size() ):
			if data[ y ][ x ] == 1:
				var x2 = pos.x + x
				var y2 = pos.y + y
				var color = ground.img.get_pixel( x2, y2 )
				if not ground.is_solid_color( color ):
					if color != Color.BLACK:
						ground.img.set_pixel( x2, y2, Color.BLACK )
						@warning_ignore( "narrowing_conversion" )
						pixels_dug.append( Vector2i( x2, y2 ) )
						is_dug = true
	
	if is_dug:
		ground.update_grid_from_pixels( pixels_dug )
	
	return is_dug


func check_rect( rect: Rect2i ) -> bool:
	var is_clear: bool = true
	for y in range( rect.position.y, rect.position.y + rect.size.y ):
		for x in range( rect.position.x, rect.position.x + rect.size.x ):
			if ground.img.get_pixel( x, y ) != Color.BLACK:
				is_clear = false
	
	return is_clear


func on_bullet_fired( bullet: TUN_Bullet ) -> void:
	var sound: AudioStreamPlayer = sounds.LaserFire
	sound.play()
	create_clones( bullet )


func on_bullet_moved( bullet: TUN_Bullet ) -> void:
	var pos: Vector2i = Vector2i(
		floor( bullet.position.x ),
		floor( bullet.position.y ),
	)
	
	# Loop through all the points
	var temp_pos: Vector2i = bullet.last_pos
	var diff = pos - temp_pos
	var step = Vector2i.ZERO
	if diff.x > 0:
		step.x = 1
	elif diff.x < 0:
		step.x = -1
	if diff.y > 0:
		step.y = 1
	elif diff.y < 0:
		step.y = -1
	
	var is_collided: bool = false
	var explode_point: Vector2i = Vector2i.ZERO
	var last_pos = temp_pos
	while not temp_pos == pos:
		if check_bullet_collisions( temp_pos, bullet ):
			if not is_collided:
				explode_point = last_pos
			is_collided = true
		last_pos = temp_pos
		temp_pos += step
	
	if check_bullet_collisions( pos, bullet ):
		if not is_collided:
			explode_point = last_pos
		is_collided = true
	
	if is_collided:
		bullet.modulate.a = 0
		bullet.destroy()
		var sound: AudioStreamPlayer = sounds.LaserHit
		sound.play()
		explode( {
			"pos": explode_point,
			"spread": false,
			"sparks": 12,
			"min_duration": 0.1,
			"max_duration": 0.2,
			"min_speed": 1.0,
			"max_speed": 12.0,
		} )


func get_tank_collision( pos: Vector2i, active_tank: TUN_Tank ) -> TUN_Tank:
	for tank in tanks:
		if active_tank == tank:
			continue
		var data = Tun.tank_data[ tank.direction ]
		for y in range( data.size() ):
			for x in range( data[ y ].size() ):
				if data[ y ][ x ] == 1:
					if tank.position.x + x == pos.x and tank.position.y + y == pos.y:
						return tank
	return null


func check_bullet_collisions( pos: Vector2i, bullet: TUN_Bullet ) -> bool:
	var tank_collision = get_tank_collision( pos, bullet.tank )
	if tank_collision != null:
		var sound: AudioStreamPlayer = sounds.TankHit
		sound.play()
		tank_collision.hit( bullet )
		return true
	var color = ground.img.get_pixel( pos.x, pos.y )
	return color != Color.BLACK 


func explode( data: Dictionary ) -> void:
	var da: float = TAU / data.sparks
	var angle: float = 0
	for i in range( data.sparks ):
		var pixel: TUN_Pixel = PIXEL_SCENE.instantiate()
		pixel.position = data.pos
		pixel.min_duration = data.min_duration
		pixel.max_duration = data.max_duration
		pixel.min_speed = data.min_speed
		pixel.max_speed = data.max_speed
		backgrounds[ 0 ].add_child( pixel )
		if data.spread:
			pixel.angle = angle
			angle += da
		create_clones( pixel )


func on_pixel_moved( pixel: TUN_Pixel ) -> void:
	var pos: Vector2i = pixel.position
	var color = ground.img.get_pixel( pos.x, pos.y )
	if not ground.is_solid_color( color ):
		ground.img.set_pixel( pos.x, pos.y, Color.BLACK )
		img_needs_update = true
	else:
		pixel.destroy()


func on_tank_destroyed( tank: TUN_Tank ) -> void:
	var sound: AudioStreamPlayer = sounds.TankExploded
	sound.play()
	explode( {
		"pos": tank.position + Vector2( 4, 3 ),
		"spread": true,
		"sparks": 50.0,
		"min_duration": 0.5,
		"max_duration": 1.0,
		"min_speed": 10.0,
		"max_speed": 30.0,
	} )
	
	# Remove
	tanks.erase( tank )
	dead_tanks.append( tank )
	
	# If last tank
	if tanks.size() == 1:
		winner = tanks[ 0 ]
		winner.is_alive = false
		winner.score += 1
		is_waiting_for_bullets_to_end = true
		wait_time_end = Time.get_ticks_msec() + 10000


func end_round() -> void:
	for tank in all_tanks:
		tank.set_physics_process( false )
		tank.set_process( false )
	round_num += 1
	show_round_panel()
	await get_tree().create_timer( 2.0 + all_tanks.size() * 0.25 ).timeout
	if winner.score >= Tun.SCORES[ Tun.settings.SCORE ]:
		Globals.is_menu_page = true
		Tun.ground = null
		var game_over: TUN_GameOver = $GameOver 
		winner.is_winner = true
		var temp_tanks: Array = []
		temp_tanks.append_array( tanks )
		temp_tanks.append_array( dead_tanks )
		for t in temp_tanks:
			t.set_process( false )
			t.set_physics_process( false )
		game_over.tanks = []
		for temp in temp_tanks:
			var tank_stats := {
				"player_id": temp.player_id,
				"is_winner": temp.is_winner,
				"display_name": temp.display_name,
				"color1": temp.color1,
				"color2": temp.color2,
				"score": temp.score,
				"kills": temp.kills,
				"killed": temp.killed,
				"shots": temp.shots,
				"hits": temp.hits,
				"accuracy": temp.accuracy,
				"meters_dug": temp.meters_dug,
				"meters_moved": temp.meters_moved,
				"time_in_base": temp.time_in_base
			}
			game_over.tanks.append( tank_stats )
			if temp.is_winner:
				game_over.winner = tank_stats
		game_over.texture_image = ground.img_texture
		game_over.begin()
	else:
		await get_tree().create_timer( 2.0 ).timeout
		reset_game()


func show_round_panel() -> void:
	var panel = $RoundPanel
	panel.modulate.a = 0
	panel.get_node( "MC/VB/HBTitle/Label" ).text = (
		tr( "TR_ROUND_PRE" ) + ( " %s" % round_num ) + tr( "TR_ROUND_POST" ) + ":"
	)
	panel.get_node( "MC/VB/HBTitle/Label2" ).text = winner.display_name
	panel.get_node( "MC/VB/HBTitle/Label2" ).modulate = winner.color1
	var rows = [
		panel.get_node( "MC/VB/HB/HB" ),	# 1
		panel.get_node( "MC/VB/HB/HB2" ),	# 2
		panel.get_node( "MC/VB/HB/HB3" ),	# 3
		panel.get_node( "MC/VB/HB/HB4" ),	# 4
		panel.get_node( "MC/VB/HB2/HB" ),	# 5
		panel.get_node( "MC/VB/HB2/HB2" ),	# 6
		panel.get_node( "MC/VB/HB2/HB3" ),	# 7
		panel.get_node( "MC/VB/HB2/HB4" ),	# 8
		panel.get_node( "MC/VB/HB3/HB" ),	# 9
		panel.get_node( "MC/VB/HB3/HB2" ),	# 10
		panel.get_node( "MC/VB/HB3/HB3" ),	# 11
		panel.get_node( "MC/VB/HB3/HB4" ),	# 12
	]
	var row_id: int = 0
	all_tanks.sort_custom( func( a, b ): return a.score > b.score )
	for tank in all_tanks:
		rows[ row_id ].get_child( 0 ).modulate = tank.color1
		rows[ row_id ].get_child( 0 ).text = tank.display_name
		rows[ row_id ].get_child( 1 ).text = str( tank.score )
		row_id += 1
	if row_id < 4:
		var hb: HBoxContainer = panel.get_node( "MC/VB/HB" )
		hb.alignment = BoxContainer.ALIGNMENT_CENTER
	if row_id < 5:
		panel.get_node( "MC/VB/HB2" ).hide()
		panel.get_node( "MC/VB/HB3" ).hide()
	elif row_id < 10:
		panel.get_node( "MC/VB/HB3" ).hide()
	for i in range( row_id, rows.size() ):
		rows[ i ].hide()
	panel.show()
	var tween = create_tween()
	tween.tween_property( panel, "modulate:a", 1.0, 1.0 )
	tween.tween_property( panel, "modulate:a", 1.0, 2.0 + all_tanks.size() * 0.25 )
	tween.tween_property( panel, "modulate:a", 0.0, 1.0 )


func reset_game() -> void:
	Tun.bullet_count = 0
	for tank: TUN_Tank in dead_tanks:
		tanks.append( tank )
	dead_tanks = []
	
	for tank: TUN_Tank in tanks:
		reset_tank_position( tank )
		tank.reset()


func on_grid_path_generated( path: Array, color: Color ) -> void:
	if not Globals.is_debug: return
	# Create labels
	for background in backgrounds:
		var line: Line2D = Line2D.new()
		line.modulate.a = 0.35
		#line.modulate.a = 0
		line.default_color = color
		line.width = 5
		background.add_child( line )
		for i in range( path.size() ):
			line.add_point( Vector2( path[ i ].x + 4.5, path[ i ].y + 4.5 ) )
		var tween = create_tween()
		tween.tween_property( line, "modulate:a", 0.0, 8.0 )
		await tween.finished
		line.queue_free()
