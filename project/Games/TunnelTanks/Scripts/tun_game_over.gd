extends CanvasLayer
class_name TUN_GameOver


const ROW_SCENE: PackedScene = preload( "res://Games/TunnelTanks/Scenes/tun_players_row.tscn" )
const FONT: FontFile = preload( "res://Assets/Fonts/AbrilFatface-Regular.ttf" )


var texture_image: ImageTexture
var winner: Dictionary
var tanks: Array
var leaderboard: Dictionary = {
	"Most Kills": { "tank_id": -1, "val": 0, "text": "TR_MOST_DEADLY" },
	"Least Kills": { "tank_id": -1, "val": INF, "text": "TR_LEAST_KILLS" },
	"Most Hits": { "tank_id": -1, "val": 0, "text": "TR_MOST_HITS" },
	"Least Hits": { "tank_id": -1, "val": INF, "text": "TR_LEAST_HITS" },
	"Most Accurate": { "tank_id": -1, "val": 0, "text": "TR_MOST_ACCURATE" },
	"Least Accurate": { "tank_id": -1, "val": INF, "text": "TR_LEAST_ACCURATE" },
	"Most Travelled": { "tank_id": -1, "val": 0, "text": "TR_MOST_TRAVELLED" },
	"Least Travelled": { "tank_id": -1, "val": INF, "text": "TR_LEAST_TRAVELLED" },
	"Most Dug": { "tank_id": -1, "val": 0, "text": "TR_MOST_DUG" },
	"Least Dug": { "tank_id": -1, "val": INF, "text": "TR_LEAST_DUG" },
	"Most Killed": { "tank_id": -1, "val": 0, "text": "TR_MOST_KILLED" },
	"Least Killed": { "tank_id": -1, "val": INF, "text": "TR_LEAST_KILLED" },
	"Most Base Time": { "tank_id": -1, "val": 0, "text": "TR_MOST_BASE_TIME" },
	"Least Base Time": { "tank_id": -1, "val": INF, "text": "TR_LEAST_BASE_TIME" },
}
var leaders: Dictionary = {}
var awards: Array = []


@onready var title: Label = $MC/VB/TitleLabel
@onready var show_map_button: Button = $MC/VB/HB/ShowMapButton
@onready var stats_panel: Panel = $MC/VB/StatsPanel
@onready var stats_vb: VBoxContainer = $MC/VB/StatsPanel/MC/SC/StatsVB


func begin() -> void:
	show_map_button.text = tr( "TR_SHOW_MAP" )
	var mc = $MC
	var pl = $PL/GameMap
	mc.modulate.a = 0
	pl.modulate.a = 0
	show()
	var tween = create_tween()
	tween.set_parallel( true )
	tween.tween_property( mc, "modulate:a", 1.0, 1.0 )
	tween.tween_property( pl, "modulate:a", 1.0, 1.0 )
	var game_map: Sprite2D = $PL/GameMap
	game_map.texture = texture_image
	@warning_ignore( "integer_division" )
	game_map.position.x = get_window().content_scale_size.x / 2
	@warning_ignore( "integer_division" )
	game_map.position.y = get_window().content_scale_size.y / 2
	var content_scale = get_window().content_scale_size
	var scale_x: float = float( content_scale.x ) / float( game_map.texture.get_width() )
	var scale_y: float = float( content_scale.y ) / float( game_map.texture.get_height() )
	var new_scale = min( scale_x, scale_y )
	game_map.scale = Vector2( new_scale, new_scale )
	visible = true
	title.text = tr( "TR_PLAYER_WINS_PRE", " " ) + winner.display_name + tr( "TR_PLAYER_WINS_POST" )
	title.label_settings.font_color = winner.color2
	title.label_settings.shadow_color = Color( winner.color1, 0.5 )
	
	tanks.sort_custom( func( a, b ): return a.player_id < b.player_id )
	
	var col: int = 0
	var hb_row: HBoxContainer
	for tank in tanks:
		leaders[ tank.player_id ] = []
		#leaders.append( [] )
		if col == 0:
			hb_row = ROW_SCENE.instantiate()
			stats_vb.add_child( hb_row )
		var data_title: Label = hb_row.get_child( col + 1 ).get_child( 0 )
		var data_stats: Label = hb_row.get_child( col + 1 ).get_child( 1 )
		awards.append( hb_row.get_child( col + 1 ).get_child( 2 ) )
		data_title.get_parent().visible = true
		data_title.text = tank.display_name
		data_title.label_settings = LabelSettings.new()
		data_title.label_settings.font = FONT
		data_title.label_settings.font_size = 38
		data_title.label_settings.font_color = tank.color2
		data_title.label_settings.shadow_color = Color( tank.color1, 0.5 )
		var stats_text = ""
		stats_text += ( tr( "TR_SCORE" ) + ":" ).rpad( 17 ) + "%s\n" % tank.score
		stats_text += ( tr( "TR_KILLS" ) + ":" ).rpad( 17 ) + "%s\n" % tank.kills
		stats_text += ( tr( "TR_SHOTS_FIRED" ) + ":" ).rpad( 17 ) + "%s\n" % tank.shots
		stats_text += ( tr( "TR_SHOTS_HIT" ) + ":" ).rpad( 17 ) + "%s\n" % tank.hits
		var pct: float = 0.0
		if tank.shots > 0:
			pct = float( tank.hits ) / float( tank.shots ) * 100.0
		tank.accuracy = pct
		stats_text += ( tr( "TR_HIT_PERCENT" ) + ":" ).rpad( 17 ) + "%2.2f%%\n" % pct
		stats_text += ( tr( "TR_METERS_MOVED" ) + ":" ).rpad( 17 ) + "%s\n" % tank.meters_moved
		stats_text += ( tr( "TR_METERS_DUG" ) + ":" ).rpad( 17 ) + "%s\n" % tank.meters_dug
		data_stats.text = stats_text
		
		col += 1
		if col > 1:
			col = 0
	
	if tanks.size() > 2:
		stats_panel.size.y = 445
		stats_panel.position.y = 90
		stats_panel.get_node( "MC" ).position.y = 0
	else:
		stats_panel.size.y = 235
		stats_panel.position.y = 190
		stats_panel.get_node( "MC" ).position.y = 0
	
	calc_stats()


func calc_stats() -> void:
	
	# Populate the leaderboard
	for tank in tanks:
		if tank.kills > leaderboard[ "Most Kills" ].val:
			leaderboard[ "Most Kills" ].val = tank.kills
			leaderboard[ "Most Kills" ].tank_id = tank.player_id
		if tank.kills < leaderboard[ "Least Kills" ].val:
			leaderboard[ "Least Kills" ].val = tank.kills
			leaderboard[ "Least Kills" ].tank_id = tank.player_id
		if tank.hits > leaderboard[ "Most Hits" ].val:
			leaderboard[ "Most Hits" ].val = tank.hits
			leaderboard[ "Most Hits" ].tank_id = tank.player_id
		if tank.hits < leaderboard[ "Least Hits" ].val:
			leaderboard[ "Least Hits" ].val = tank.hits
			leaderboard[ "Least Hits" ].tank_id = tank.player_id
		if tank.accuracy > leaderboard[ "Most Accurate" ].val:
			leaderboard[ "Most Accurate" ].val = tank.accuracy
			leaderboard[ "Most Accurate" ].tank_id = tank.player_id
		if tank.accuracy < leaderboard[ "Least Accurate" ].val:
			leaderboard[ "Least Accurate" ].val = tank.accuracy
			leaderboard[ "Least Accurate" ].tank_id = tank.player_id
		if tank.meters_moved > leaderboard[ "Most Travelled" ].val:
			leaderboard[ "Most Travelled" ].val = tank.meters_moved
			leaderboard[ "Most Travelled" ].tank_id = tank.player_id
		if tank.meters_moved < leaderboard[ "Least Travelled" ].val:
			leaderboard[ "Least Travelled" ].val = tank.meters_moved
			leaderboard[ "Least Travelled" ].tank_id = tank.player_id
		if tank.meters_dug > leaderboard[ "Most Dug" ].val:
			leaderboard[ "Most Dug" ].val = tank.meters_dug
			leaderboard[ "Most Dug" ].tank_id = tank.player_id
		if tank.meters_dug < leaderboard[ "Least Dug" ].val:
			leaderboard[ "Least Dug" ].val = tank.meters_dug
			leaderboard[ "Least Dug" ].tank_id = tank.player_id
		if tank.killed > leaderboard[ "Most Killed" ].val:
			leaderboard[ "Most Killed" ].val = tank.killed
			leaderboard[ "Most Killed" ].tank_id = tank.player_id
		if tank.killed < leaderboard[ "Least Killed" ].val:
			leaderboard[ "Least Killed" ].val = tank.killed
			leaderboard[ "Least Killed" ].tank_id = tank.player_id
		if tank.time_in_base > leaderboard[ "Most Base Time" ].val:
			leaderboard[ "Most Base Time" ].val = tank.time_in_base
			leaderboard[ "Most Base Time" ].tank_id = tank.player_id
		if tank.time_in_base < leaderboard[ "Least Base Time" ].val:
			leaderboard[ "Least Base Time" ].val = tank.time_in_base
			leaderboard[ "Least Base Time" ].tank_id = tank.player_id
	
	# Add the leader titles to the leaders arra
	for leader_title in leaderboard.keys():
		var leader = leaderboard[ leader_title ]
		if leader.tank_id != -1:
			leaders[ leader.tank_id ].append( leader_title )
	
	# Assign the awards
	for i in range( tanks.size() ):
		var ls: Array = leaders[ tanks[ i ].player_id ]
		
		if has_award( ls, "Most Kills" ) and not tanks[ i ].is_winner:
			awards[ i ].text = tr( "TR_VALIANT_DEFEAT" )
		else:
			if ls.size() == 0:
				awards[ i ].text = ""
			else:
				awards[ i ].text = tr( leaderboard[ ls.pick_random() ].text )


func has_award( stat: Array, stat_name: String ) -> bool:
	return stat.find( stat_name ) > -1


func _on_menu_button_pressed() -> void:
	Tun.ground = null
	get_tree().change_scene_to_packed( Tun.scenes.menu )


func _on_show_map_button_pressed() -> void:
	if show_map_button.text == tr( "TR_SHOW_MAP" ):
		show_map_button.text = tr( "TR_HIDE_MAP" )
		var tween = create_tween()
		tween.set_parallel( true )
		tween.tween_property( stats_panel, "modulate:a", 0.0, 0.5 )
		tween.tween_property( title, "modulate:a", 0.0, 0.5 )
	else:
		show_map_button.text = tr( "TR_SHOW_MAP" )
		var tween = create_tween()
		tween.set_parallel( true )
		tween.tween_property( stats_panel, "modulate:a", 1.0, 0.5 )
		tween.tween_property( title, "modulate:a", 1.0, 0.5 )
