extends Panel


func get_containers() -> Array:
	return [
		$HB/Cont,
		$HB/Cont2
	]


func get_ui_items() -> Array:
	return [
		$HB/ColorRect
	]
