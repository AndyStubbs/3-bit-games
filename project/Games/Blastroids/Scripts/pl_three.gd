extends Panel


func get_containers() -> Array:
	return [
		$HB/Cont,
		$HB/Cont2,
		$HB/Cont3
	]


func get_ui_items() -> Array:
	return [
		$HB/ColorRect,
		$HB/ColorRect2
	]


func setup_viewport() -> void:
	for container in get_containers():
		var subviewport = container.get_node( "SubViewport" )
		subviewport.size.x = 639
		container.size.x = 639


func setup_ui() -> void:
	for container in get_containers():
		var ship_data = container.get_node( "SubViewport/CanvasLayer/PlayerUI/ShipData" )
		var weapons_data = container.get_node( "SubViewport/CanvasLayer/PlayerUI/WeaponsData" )
		var minimap = container.get_node( "SubViewport/CanvasLayer/PlayerUI/Panel" )
		var coords = container.get_node( "SubViewport/CanvasLayer/PlayerUI/Control" )
		var lives = container.get_node( "SubViewport/CanvasLayer/PlayerUI/Lives" )
		ship_data.texture = BlastGame.PLAYER_UI_SMALL
		ship_data.get_node( "HealthBar" ).size.x = 211
		ship_data.get_node( "ShieldsBar" ).size.x = 211
		ship_data.get_node( "EnergyBar" ).size.x = 211
		ship_data.size.x = 286
		weapons_data.position.x = 315
		minimap.position.x = 258
		coords.position.x = 258
		if Blast.data.settings.lives_count == 4:
			lives.scale = Vector2( 0.95, 0.95 )
			lives.position.x = 20
		elif Blast.data.settings.lives_count == 5:
			lives.scale = Vector2( 0.8, 0.8 )
			lives.position.x = 15
		elif Blast.data.settings.lives_count > 5:
			lives.scale = Vector2( 0.7, 0.7 )
			lives.position.x = 10


func _ready() -> void:
	setup_viewport()
	setup_ui()
