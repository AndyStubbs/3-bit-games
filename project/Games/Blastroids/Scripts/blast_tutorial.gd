extends Control
class_name BlastTutorial


var game: BlastGame
var steps: Array = [
	{
		"start_pos": Vector2( 1000, -1000 ),
		"settings": {
			"map_size": 2,
			"map_type": 0,
			"rock_density": 0,
			"crate_density": 0,
			"lives_count": -1,
			"added_cpus": 0,
			"game_mode": 0,
			"show_crosshairs": 0
		},
		"substeps": [
			{
				# Just thrust forward
				"enabled_actions": [ "Up_" ],
				"messages": 3,
				"goal": "motion"
			}, {
				# Start reverse thrust
				"enabled_actions": [ "Down_" ],
				"messages": 3,
				"goal": "non_zero_rotation"
			},  {
				# Come to a complete stop
				"enabled_actions": [ "Down_" ],
				"messages": 2,
				"goal": "stopped"
			}, {
				# Travel to the first beacon
				"enabled_actions": [ "Up_", "Left_", "Right_", "Down_" ],
				"messages": 3,
				"goal": "beacon",
				"color": Color.RED,
				"beacon": Vector2( 1500, -500 ),
				"delay": 1
			}, {
				# Travel to the moving beacon
				"enabled_actions": [ "Up_", "Left_", "Right_", "Down_" ],
				"messages": 1,
				"goal": "beacon",
				"color": Color.CORNFLOWER_BLUE,
				"beacon_radius": 1000,
				"beacon_mid_pos": Vector2( 1500, -500 ),
			},{
				# Travel through the asteroid field to the distant beacon
				"enabled_actions": [ "Up_", "Left_", "Right_", "Down_" ],
				"messages": 3,
				"goal": "beacon",
				"color": Color.WEB_GREEN,
				"beacon": Vector2( -3000, 2500 ),
				"rocks": 150
			}, {
				# Tutorial Completed
				"enabled_actions": [ "Up_", "Left_", "Right_", "Down_" ],
				"goal": "none",
				"messages": 2
			}
		]
	},
	{
		"start_pos": Vector2( 1000, -1000 ),
		"settings": {
			"map_size": 2,
			"map_type": 0,
			"rock_density": 0,
			"crate_density": 0,
			"lives_count": -1,
			"added_cpus": 0,
			"game_mode": 0,
			"show_crosshairs": 1
		},
		"substeps": [
			{
				# Destroy Asteroid
				"enabled_actions": [ "Up_", "Left_", "Right_", "Down_", "Fire_" ],
				"messages": 3,
				"rock": Vector2( 1200, -800 ),
				"rock_energy": 0,
				"goal": "destroy_rock"
			},
			{
				# Pickup mass cannon
				"enabled_actions": [ "Up_", "Left_", "Right_", "Down_", "Fire_" ],
				"messages": 3,
				"crate": Vector2( 900, -900 ),
				"pickup": "mass",
				"goal": "pickup"
			},
			{
				# Select mass cannon
				"messages": 2,
				"select_weapon": "mass",
				"goal": "select"
			},
			{
				# Hit any asteroid with the mass cannon
				"messages": 2,
				"hit_with": "mass",
				"goal": "hit_rock",
				"rock": Vector2( 1200, -800 ),
				"rock_size": "small",
				"rock_energy": 0
			},
			{
				# Pickup the charge cannon
				"messages": 2,
				"crate": Vector2( 900, -900 ),
				"pickup": "charge",
				"goal": "pickup"
			},
			{
				# Destroy asteroid with charge cannon
				"messages": 3,
				"hit_with": "charge",
				"rock": Vector2( 1000, -1000 ),
				"rock_radius": 300,
				"rock_energy": 0,
				"goal": "destroy_rock"
			},
			{
				# Pickup spread cannon
				"messages": 1,
				"crate": Vector2( 900, -900 ),
				"pickup": "spread",
				"goal": "pickup"
			},
			{
				# Destroy asteroid with spread cannon
				"messages": 3,
				"hit_with": "spread",
				"rock": Vector2( 1000, -1000 ),
				"rock_radius": 300,
				"rock_energy": 0,
				"goal": "destroy_rock"
			},
			{
				# Tutorial Completed
				"goal": "none",
				"messages": 2
			}
		]
	},
	{
		"start_pos": Vector2( 1000, -1000 ),
		"settings": {
			"map_size": 2,
			"map_type": 0,
			"rock_density": 0,
			"crate_density": 0,
			"lives_count": -1,
			"added_cpus": 0,
			"game_mode": 0,
			"show_crosshairs": 1
		},
		"substeps": [
			{
				# Destroy energy asteroid
				"messages": 3,
				"rock": Vector2( 1200, -800 ),
				"rock_energy": 1,
				"goal": "destroy_rock"
			},
			{
				"enabled_actions": [ "Left_", "Right_", "Down_", "Fire_" ],
				"messages": 3,
				"hit_with_missile": true,
				"drain_energy": true,
				"crate": Vector2( 1000, -1000 ),
				"crate_radius": 300,
				"crate_count": 9,
				"goal": "energy_recharged",
				"delay": 0.5
			},
			{
				# Tutorial Completed
				"goal": "none",
				"messages": 2
			}
		]
	}, {
		"start_pos": Vector2( 1000, -1000 ),
		"settings": {
			"map_size": 2,
			"map_type": 0,
			"rock_density": 0,
			"crate_density": 0,
			"lives_count": -1,
			"added_cpus": 0,
			"game_mode": 0,
			"show_crosshairs": 1
		},
		"substeps": [
			{
				# Pickup bomb
				"messages": 1,
				"crate": Vector2( 900, -900 ),
				"pickup": "bomb",
				"goal": "pickup"
			},
			{
				# Destroy asteroid with bomb
				"messages": 3,
				"hit_with": "bomb",
				"rock": Vector2( 1000, -1000 ),
				"rock_radius": 300,
				"rock_energy": 0,
				"goal": "destroy_rock"
			},
			{
				# Pickup missile
				"messages": 1,
				"pickup": "missile",
				"goal": "pickup",
				"crate": Vector2( 900, -900 ),
				"crate_maxed": true
			},
			{
				# Destroy ship with missiles
				"messages": 3,
				"ship": Vector2( 1200, -800 ),
				"ship_disabled": true,
				"ship_weak": true,
				"goal": "destroy_ship"
			},
			{
				# Destroy ship
				"messages": 3,
				"ship": Vector2( 2000, -2000 ),
				"ship_weak": true,
				"ship_disabled": true,
				"ship_enabled_delay": 10.0,
				"goal": "destroy_ship",
				"crate": Vector2( 1000, -1000 ),
				"crate_radius": 300,
				"crate_count": 9,
			},
			{
				# Tutorial Completed
				"goal": "none",
				"messages": 1
			}
		]
	}
]
var data: Dictionary
var substep: Dictionary
var ship: BlastShipBody
var enemy_ship: BlastShipBody
var items: Array = []
var beacon: BlastBeacon
var beacon_angle: float = 0
var is_waiting_for_reset_step: bool = false


@onready var title: Label = $Panel/VB/Title
@onready var contents: Label = $Panel/VB/Contents
@onready var tutorial_complete = $TutorialCompleteSound


func init( new_game: BlastGame ) -> void:
	game = new_game
	data = steps[ Blast.data.tutorial_step ]
	if Blast.data.tutorial_step == steps.size() - 1:
		$Panel2/VB/HB/NextButton.disabled = true
	if Blast.data.tutorial_step == 0:
		$Panel2/VB/HB/PreviousButton.disabled = true


func get_settings() -> Dictionary:
	return data.settings


func start() -> void:
	title.text = tr( "TR_BLAST_TUT_%d_TITLE" % Blast.data.tutorial_step )
	ship = game.ships[ 0 ]
	ship.position = data.start_pos
	start_substep()


func start_substep() -> void:
	is_waiting_for_reset_step = false
	substep = data.substeps[ Blast.data.tutorial_substep ]
	if game.on_body_hit.is_connected( on_body_hit ):
		game.on_body_hit.disconnect( on_body_hit )
	if game.on_pickup_destroyed.is_connected( on_pickup_destroyed ):
		game.on_pickup_destroyed.disconnect( on_pickup_destroyed )
	if substep.has( "enabled_actions" ):
		ship.disable_controls()
		ship.enable_controls( substep.enabled_actions )
	else:
		ship.enable_controls( ship.ACTION_NAMES )
	
	# Need to drain energy before delay because goal is to recharge energy
	if substep.has( "drain_energy" ):
		ship.energy = ship.energy * 0.3
	if substep.has( "delay" ):
		await get_tree().create_timer( substep.delay ).timeout
	contents.text = ""
	for i in range( substep.messages ):
		var msg = "TR_BLAST_TUT_%d_%d_%d" % [
			Blast.data.tutorial_step, Blast.data.tutorial_substep, i
		]
		contents.text += tr( msg )
	if substep.has( "beacon" ):
		beacon = game.scenes.BEACON.instantiate()
		beacon.modulate = substep.color
		beacon.position = substep.beacon
		game.add_body( beacon )
		beacon.init( game )
		ship.clones[ 0 ].target_beacon = beacon
	if substep.has( "beacon_radius" ):
		beacon = game.scenes.BEACON.instantiate()
		beacon.modulate = substep.color
		game.add_body( beacon )
		beacon.init( game )
	if substep.has( "rocks" ):
		await game.show_loading_screen()
		game.create_rocks( substep.rocks, true )
		await get_tree().physics_frame
		game.hide_loading_screen()
	if substep.has( "rock" ):
		var rock_size = "medium"
		if substep.has( "rock_size" ):
			rock_size = substep.rock_size
		var rock = game.create_rock( rock_size, substep.rock_energy )
		if substep.has( "rock_radius" ):
			var a = randf_range( 0, TAU )
			rock.position = Vector2(
				substep.rock.x + cos( a ) * substep.rock_radius,
				substep.rock.y + sin( a ) * substep.rock_radius
			)
		else:
			rock.position = substep.rock
	if substep.has( "crate" ):
		if substep.has( "crate_radius" ):
			var count: int = 1
			if substep.has( "crate_count" ):
				count = substep.crate_count
			for i in range( count ):
				var crate: BlastCrateBody
				if substep.has( "pickup" ):
					crate = game.create_crate( substep.pickup )
				else:
					crate = game.create_crate()
				var a = randf_range( 0, TAU )
				crate.position = Vector2(
					substep.crate.x + cos( a ) * substep.crate_radius,
					substep.crate.y + sin( a ) * substep.crate_radius
				)
		else:
			var crate: BlastCrateBody
			if substep.has( "pickup" ):
				crate = game.create_crate( substep.pickup )
			else:
				crate = game.create_crate()
			crate.position = substep.crate
			if substep.has( "crate_maxed" ):
				crate.is_max_count = true
		if substep.goal == "pickup":
			game.on_pickup_destroyed.connect( on_pickup_destroyed )
	if substep.has( "hit_with_missile" ):
		var missile: BlastMissileBody = game.scenes.MISSILE_BODY.instantiate()
		missile.position = ship.position + Vector2.RIGHT * 100
		game.add_body( missile )
		missile.is_bomb = true
		missile.init( ship, "bomb" )
		missile.fire( Vector2.LEFT * 160, Color.RED, PI )
		ship.linear_velocity = Vector2.ZERO
	if substep.has( "ship" ):
		enemy_ship = game.scenes.SHIP_BODY.instantiate()
		enemy_ship.world_id = -1
		game.add_body( enemy_ship )
		game.ships.append( enemy_ship )
		game.rigid_bodies.append( enemy_ship )
		enemy_ship.setup_ship( {
			"colors": null,
			"name": "CPU 1",
			"controls": "CPU",
			"image_id": null,
			"name_changed": false
		} )
		enemy_ship.init( game )
		enemy_ship.position = substep.ship
		if substep.has( "ship_disabled" ):
			enemy_ship.disable_controls()
		if substep.has( "ship_weak" ):
			enemy_ship.max_shields = enemy_ship.max_shields * 0.25
			enemy_ship.shields = enemy_ship.max_shields
			enemy_ship.max_health = enemy_ship.max_health * 0.35
			enemy_ship.health = enemy_ship.max_health
		ship.clones[ 0 ].create_enemy_ship_vectors()
		enable_delayed()
	
	# Setup goals
	if substep.goal == "none":
		tutorial_complete.play()
	if substep.goal == "hit_rock":
		game.on_body_hit.connect( on_body_hit )
	elif substep.goal == "destroy_rock":
		game.on_body_hit.connect( on_body_hit )
	if substep.has( "hit_with" ) and substep.hit_with == "bomb":
		game.on_missile_destroyed.connect( on_missile_destroyed )
	
	# Disable thrust so that ship can get hit by missile
	if substep.has( "hit_with_missile" ):
		await get_tree().create_timer( 0.5 ).timeout
		ship.enable_controls( [ "Up_" ] )


func enable_delayed() -> void:
	if substep.has( "ship_enabled_delay" ):
		await get_tree().create_timer( substep.ship_enabled_delay ).timeout
		if enemy_ship and not enemy_ship.is_destroyed:
			enemy_ship.enable_controls( [ "Left_", "Up_", "Right_", "Down_", "Fire_" ] )


func next_substate() -> void:
	if beacon:
		ship.clones[ 0 ].target_beacon = null
		beacon.destroy()
		beacon = null
	if Blast.data.tutorial_substep <  data.substeps.size() - 1:
		Blast.data.tutorial_substep += 1
		start_substep()


func reset_tutorial() -> void:
	get_tree().change_scene_to_packed( Blast.scenes.game )


func on_body_hit( weapon: String, body: RigidBody2D ) -> void:
	if substep.goal == "hit_rock" and body is BlastRockBody and weapon == substep.hit_with:
		call_deferred( "next_substate" )
	if substep.goal == "destroy_rock" and body is BlastRockBody:
		if body.is_destroyed:
			if substep.has( "hit_with" ):
				if weapon == substep.hit_with:
					call_deferred( "next_substate" )
				else:
					if not is_waiting_for_reset_step:
						is_waiting_for_reset_step = true
						await get_tree().create_timer( 1.0 ).timeout
						call_deferred( "start_substep" )
			else:
				call_deferred( "next_substate" )


func on_pickup_destroyed( weapon: String ) -> void:
	if substep.goal == "pickup" and weapon == substep.pickup and not is_waiting_for_reset_step:
		is_waiting_for_reset_step = true
		call_deferred( "start_substep" )


func on_missile_destroyed() -> void:
	var crate: BlastCrateBody
	crate = game.create_crate( "bomb" )
	crate.position = Vector2( 900, -900 )


func _physics_process( delta: float ) -> void:
	
	# Move Beacon
	if beacon and substep.has( "beacon_radius" ):
		beacon.position = substep.beacon_mid_pos + Vector2(
			cos( beacon_angle ) * substep.beacon_radius,
			sin( beacon_angle ) * substep.beacon_radius
		)
		beacon_angle += ( PI / 30 ) * delta
	
	# Check substep goals
	if substep.goal == "motion" and ship.speed > 10000:
		next_substate()
	elif substep.goal == "non_zero_rotation" and ship.rotation != 0:
		next_substate()
	elif substep.goal == "stopped" and ship.speed < 100:
		next_substate()
	elif substep.goal == "beacon":
		if beacon and ship.position.distance_squared_to( beacon.position ) < 10000:
			next_substate()
	elif substep.goal == "pickup":
		for weapon in ship.weapon_store:
			if weapon == substep.pickup:
				next_substate()
	elif substep.goal == "select":
		if ship.weapon_store[ ship.weapon_index ] == substep.select_weapon:
			next_substate()
	elif substep.goal == "energy_recharged" and ship.energy > ship.max_energy * 0.75:
		next_substate()
	elif substep.goal == "destroy_ship" and enemy_ship.is_destroyed:
		enemy_ship = null
		next_substate()
	
	# Reset tutorial if killed
	if ship.is_destroyed:
		await get_tree().create_timer( 1.5 ).timeout
		reset_tutorial()


func _on_reset_button_pressed() -> void:
	Blast.data.tutorial_substep = 0
	reset_tutorial()


func _on_quit_pressed() -> void:
	Blast.data.tutorial_substep = 0
	get_tree().change_scene_to_packed( Blast.scenes.menu )


func _on_next_button_pressed() -> void:
	if Blast.data.tutorial_step < steps.size() - 1:
		Blast.data.tutorial_step += 1
		Blast.data.tutorial_substep = 0
		get_tree().change_scene_to_packed( Blast.scenes.game )


func _on_previous_button_pressed() -> void:
	if Blast.data.tutorial_step > 0:
		Blast.data.tutorial_step -= 1
		Blast.data.tutorial_substep = 0
		get_tree().change_scene_to_packed( Blast.scenes.game )


func _on_show_controls_pressed() -> void:
	var controls: Panel = $Controls
	var tween: Tween = create_tween()
	var controls_button: Button = $Panel2/VB/HB/ControlsButton
	controls.modulate.a = 0
	controls.show()
	tween.tween_property( controls, "modulate:a", 1.0, 0.5 )
	controls_button.release_focus()
