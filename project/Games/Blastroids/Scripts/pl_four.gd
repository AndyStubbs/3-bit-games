extends Panel


func get_containers() -> Array:
	return [
		$VB/HB/Cont,
		$VB/HB/Cont2,
		$VB/HB2/Cont,
		$VB/HB2/Cont2
	]


func get_ui_items() -> Array:
	return [
		$VB/HB/ColorRect,
		$VB/ColorRect,
		$VB/HB2/ColorRect,
	]


func setup_viewport() -> void:
	var containers = get_containers()
	for container in containers:
		var subviewport = container.get_node( "SubViewport" )
		subviewport.size.x = 960
		subviewport.size.y = 538
		container.size.x = 960
		container.size.y = 538


func setup_ui() -> void:
	var index = 0
	for container in get_containers():
		var minimap = container.get_node( "SubViewport/CanvasLayer/PlayerUI/Panel" )
		var coords = container.get_node( "SubViewport/CanvasLayer/PlayerUI/Control" )
		var lives = container.get_node( "SubViewport/CanvasLayer/PlayerUI/Lives" )
		minimap.scale = Vector2( 0.9, 0.9 )
		minimap.position.x = 605
		minimap.position.y = 323
		coords.position.x = 605
		coords.position.y = 323
		lives.position.y = 500
		if index > 1:
			minimap.position.y = 317
			lives.position.y = 492
		index += 1


func _ready() -> void:
	setup_viewport()
	setup_ui()
