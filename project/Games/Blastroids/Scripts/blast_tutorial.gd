extends Control
class_name BlastTutorial


var game: BlastGame
var steps: Array = [ {
	"start_pos": Vector2( 1000, -1000 ),
	"settings": {
		"map_size": 2,
		"map_type": 0,
		"rock_density": 0,
		"crate_density": 0,
		"lives_count": 0,
		"added_cpus": 0,
		"game_mode": 0,
		"show_crosshairs": 0
	},
	"substeps": [ {
		"enabled_actions": [ "Up_" ],
		"messages": 3,
		"goal": "motion"
	}, {
		"enabled_actions": [ "Down_" ],
		"messages": 3,
		"goal": "non_zero_rotation"
	},  {
		"enabled_actions": [ "Down_" ],
		"messages": 2,
		"goal": "stopped"
	}, {
		"enabled_actions": [ "Up_", "Left_", "Right_", "Down_" ],
		"messages": 3,
		"goal": "beacon",
		"color": Color.RED,
		"beacon": Vector2( 1500, -500 ),
		"delay": 1
	}, {
		"enabled_actions": [ "Up_", "Left_", "Right_", "Down_" ],
		"messages": 1,
		"goal": "beacon",
		"color": Color.CORNFLOWER_BLUE,
		"beacon_radius": 1000,
		"beacon_mid_pos": Vector2( 1500, -500 ),
	},{
		"enabled_actions": [ "Up_", "Left_", "Right_", "Down_" ],
		"messages": 3,
		"goal": "beacon",
		"color": Color.WEB_GREEN,
		"beacon": Vector2( -3000, 2500 ),
		"rocks": 150
	}, {
		"enabled_actions": [ "Up_", "Left_", "Right_", "Down_" ],
		"goal": "none",
		"messages": 2
	} ]
} ]
var data: Dictionary
var substep_index: int = 0
var substep: Dictionary
var ship: BlastShipBody
var items: Array = []
var beacon: BlastBeacon
var beacon_angle: float = 0


@onready var title: Label = $Panel/VB/Title
@onready var contents: Label = $Panel/VB/Contents


func init( new_game: BlastGame ) -> void:
	game = new_game
	data = steps[ Blast.data.tutorial_step ]


func get_settings() -> Dictionary:
	return data.settings


func start() -> void:
	title.text = tr( "TR_BLAST_TUT_%d_TITLE" % Blast.data.tutorial_step )
	ship = game.ships[ 0 ]
	ship.position = data.start_pos
	start_substep()


func start_substep() -> void:
	substep = data.substeps[ substep_index ]
	ship.disable_controls()
	ship.enable_controls( substep.enabled_actions )
	
	if substep.has( "delay" ):
		await get_tree().create_timer( substep.delay ).timeout
	contents.text = ""
	for i in range( substep.messages ):
		var msg = "TR_BLAST_TUT_%d_%d_%d" % [ Blast.data.tutorial_step, substep_index, i ]
		contents.text += tr( msg )
	if substep.has( "beacon" ):
		beacon = BlastGame.BEACON_SCENE.instantiate()
		beacon.modulate = substep.color
		beacon.position = substep.beacon
		game.add_body( beacon )
		beacon.init( game )
	if substep.has( "beacon_radius" ):
		beacon = BlastGame.BEACON_SCENE.instantiate()
		beacon.modulate = substep.color
		game.add_body( beacon )
		beacon.init( game )
	if substep.has( "rocks" ):
		# TODO add loading screen
		game.create_rocks( substep.rocks, true )


func next_substate() -> void:
	if beacon:
		beacon.destroy()
		beacon = null
	if substep_index <  data.substeps.size() - 1:
		substep_index += 1
		start_substep()


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
