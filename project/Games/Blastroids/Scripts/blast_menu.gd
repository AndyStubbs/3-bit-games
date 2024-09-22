extends Node


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed( Blast.scenes.game )


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_packed( Globals.main_menu_scene )
