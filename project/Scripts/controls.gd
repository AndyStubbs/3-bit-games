extends Panel



@export var game_postfix: String = ""


func _ready() -> void:
	if game_postfix == "_TUN":
		$Lines/LineLT.hide()
		$Lines/LineLB.hide()
		$Lines/LineRT.hide()
		$Lines/LineRB.hide()
	if game_postfix != "":
		append_text_to_labels( self )


func append_text_to_labels( node: Node ) -> void:
	for child in node.get_children():
		if child is Label:
			if child.text != "":
				child.text += game_postfix
		if child.has_method( "get_children" ):
			append_text_to_labels( child )


func _on_close_button_pressed() -> void:
	Raf.is_paused = false
	var tween: Tween = create_tween()
	tween.tween_property( self, "modulate:a", 0.0, 0.5 )
	await tween.finished
	hide()
	AudioServer.set_bus_mute( AudioServer.get_bus_index( "Sound" ), false )
