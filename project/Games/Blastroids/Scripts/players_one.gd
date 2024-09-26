extends Panel


func get_containers() -> Array:
	return [
		$HB/Cont
	]


func get_ui_items() -> Array:
	return []


func setup_viewport() -> void:
	var container = $HB/Cont
	var subviewport = $HB/Cont/SubViewport
	subviewport.size.x = 1920
	subviewport.size.y = 1080
	container.size.x = 1920
	container.size.y = 1080


func setup_ui() -> void:
	var weapons_data = $HB/Cont/SubViewport/CanvasLayer/PlayerUI/WeaponsData
	var minimap = $HB/Cont/SubViewport/CanvasLayer/PlayerUI/Panel
	var coords = $HB/Cont/SubViewport/CanvasLayer/PlayerUI/Control
	weapons_data.position.x = 1600
	minimap.position.x = 1539
	coords.position.x = 1539


func _ready() -> void:
	setup_viewport()
	setup_ui()
