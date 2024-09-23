extends Node


@onready var map_sizes = $MC/VB/MC/PL/MC/VB/HbOptions/Panel/MC/VB/MapSizes
@onready var map_types = $MC/VB/MC/PL/MC/VB/HbOptions/Panel2/MC/VB/MapTypes
@onready var asteroid_count = $MC/VB/MC/PL/MC/VB/HbOptions/Panel3/MC/VB/AsteroidCount
@onready var crate_count = $MC/VB/MC/PL/MC/VB/HbOptions/Panel4/MC/VB/CrateCount
@onready var lives_count = $MC/VB/MC/PL/MC/VB/HbOptions/Panel5/MC/VB/LivesCount


func update_settings() -> void:
	Blast.settings.map_size = map_sizes.selected
	Blast.settings.map_type = map_types.selected
	Blast.settings.rock_density = asteroid_count.selected
	Blast.settings.crate_density = crate_count.selected
	Blast.settings.lives_count = lives_count.selected
	update_ui_state()


func update_ui_state() -> void:
	if Blast.settings.map_size <= 3:
		map_types.set_item_disabled( 1, false )
		map_types.set_item_disabled( 2, true )
	elif Blast.settings.map_size <= 2:
		map_types.set_item_disabled( 1, true )
		map_types.set_item_disabled( 2, true )
	else:
		map_types.set_item_disabled( 1, false )
		map_types.set_item_disabled( 2, false )


func _ready() -> void:
	map_sizes.select( Blast.settings.map_size )
	map_types.select( Blast.settings.map_type )
	asteroid_count.select( Blast.settings.rock_density )
	crate_count.select( Blast.settings.crate_density )
	lives_count.select( Blast.settings.lives_count )


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed( Blast.scenes.game )


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_packed( Globals.main_menu_scene )


func _on_map_sizes_item_selected( _index: int ) -> void:
	update_settings()


func _on_map_types_item_selected( _index: int ) -> void:
	update_settings()


func _on_asteroid_count_item_selected( _index: int ) -> void:
	update_settings()


func _on_crate_count_item_selected( _index: int ) -> void:
	update_settings()


func _on_lives_count_item_selected( _index: int ) -> void:
	update_settings()
