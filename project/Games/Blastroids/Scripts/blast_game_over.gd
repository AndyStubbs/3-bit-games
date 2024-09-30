extends Panel


const FONT = preload( "res://Assets/Fonts/Anton-Regular.ttf" )
const FONT2 = preload( "res://Assets/Fonts/NotoSansMono-Regular.ttf" )


const COLORS = [
	Color( "#ff4538" ),
	Color( "#ffa938" ),
	Color( "#f2ff38" ),
	Color( "#8fff38" ),
	Color( "#38ff45" ),
	Color( "#38ffa9" ),
	Color( "#38f2ff" ),
	Color( "#388fff" ),
	Color( "#4538ff" ),
	Color( "#a838ff" ),
	Color( "#ff38f2" ),
	Color( "#ff388e" )
]


var header_boxes: Array
var header_titles: Array = [
	"Player",
	"Ship Kills",
	"Asteroid Kills",
	"Crate Kills",
	"Missile Kills"
]
var labels: Array = []
var tween: Tween = null
var first_color: int = 0


@onready var hb: HBoxContainer = $VB/GridContainer/HB
@onready var hb2: HBoxContainer = $VB/GridContainer/HB2
@onready var hb3: HBoxContainer = $VB/GridContainer/HB3
@onready var hb4: HBoxContainer = $VB/GridContainer/HB4
@onready var hb5: HBoxContainer = $VB/GridContainer/HB5


func get_random_color() -> Color:
	return COLORS.pick_random()


func start( game: BlastGame ) -> void:
	Globals.is_menu_page = true
	modulate.a = 0
	show()
	update_scores( game )
	var show_tween: Tween = create_tween()
	show_tween.tween_property( self, "modulate:a", 1.0, 1.0 )
	var hide_tween: Tween = create_tween()
	hide_tween.set_parallel( true )
	for item in game.ui_items:
		hide_tween.tween_property( item, "modulate:a", 0.0, 1.0 )
	for ship in game.ships:
		for clone: BlastShip in ship.get_clones():
			if clone.has_method( "init_stars" ) and clone.is_main_ship:
				hide_tween.tween_property( clone.sprite, "modulate:a", 0.0, 1.0 )
				hide_tween.tween_property( clone.get_node( "Vector" ), "modulate:a", 0.0, 1.0 )
				hide_tween.tween_property( clone.low_energy_sprite, "modulate:a", 0.0, 1.0 )
				hide_tween.tween_property( clone.health_bar_panel, "modulate:a", 0.0, 1.0 )
			else:
				hide_tween.tween_property( clone, "modulate:a", 0.0, 1.0 )
	set_physics_process( true )


func update_scores( game: BlastGame ) -> void:
	var stats = [
		"ship_kills",
		"asteroid_kills",
		"crate_kills",
		"missile_kills"
	]
	game.ships.sort_custom(
		func( a, b ):
			if a.lives != b.lives:
				return a.lives > b.lives
			for stat in stats:
				if a.stats[ stat ] != b.stats[ stat ]:
					return a.stats[ stat ] > b.stats[ stat ]
			return true
			#if a.stats.ship_kills != b.stats.ship_kills:
				#return a.stats.ship_kills > b.stats.ship_kills
			#if a.stats.asteroid_kills != b.stats.asteroid_kills:
				#return a.stats.asteroid_kills > b.stats.asteroid_kills
			#if a.stats.crate_kills != b.stats.crate_kills:
				#return a.stats.crate_kills > b.stats.crate_kills
			#return a.stats.missile_kills > b.stats.crate_kills
	)
	
	var winner: BlastShipBody = game.ships[ 0 ]
	var winner_label = $VB/WinnerLabel
	winner_label.text = "%s Wins" % winner.display_name
	winner_label.modulate = winner.ui_color
	var grid: GridContainer = $VB/GridContainer
	for ship in game.ships:
		var label = create_label( ship.display_name, FONT2 )
		label.modulate = ship.ui_color
		grid.add_child( label )
		for stat in stats:
			var label2 = create_label( "%s" % ship.stats[ stat ], FONT2 )
			label2.modulate = ship.ui_color
			label2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			grid.add_child( label2 )


func create_label( text: String, font = FONT ) -> Label:
	var label: Label = Label.new()
	label.add_theme_font_override( "font", font )
	label.add_theme_font_size_override( "font_size", 32 )
	label.text = text
	return label


func _ready() -> void:
	hide()
	set_physics_process( false )
	header_boxes = [ hb, hb2, hb3, hb4, hb5 ]
	for i in range( header_titles.size() ):
		var box: HBoxContainer = header_boxes[ i ]
		var title: String = header_titles[ i ]
		for c in title:
			var label: Label = create_label( c )
			labels.append( label )
			box.add_child( label )


func _physics_process( _delta: float ) -> void:
	if tween == null or not tween.is_running():
		tween = create_tween()
		tween.set_parallel( true )
		for i in range( labels.size() ):
			var label = labels[ i ]
			var c = COLORS[ ( i + first_color ) % COLORS.size() ]
			tween.tween_property( label, "modulate", c, 0.15 )
		first_color += 1


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_packed( Blast.scenes.menu )
