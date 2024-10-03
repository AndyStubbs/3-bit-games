extends Node


@onready var map_sizes = $MC/VB/MC/PL/MC/VB/HbOptions/Panel/MC/VB/MapSizes
@onready var map_types = $MC/VB/MC/PL/MC/VB/HbOptions/Panel2/MC/VB/MapTypes
@onready var asteroid_count = $MC/VB/MC/PL/MC/VB/HbOptions/Panel3/MC/VB/AsteroidCount
@onready var crate_count = $MC/VB/MC/PL/MC/VB/HbOptions/Panel4/MC/VB/CrateCount
@onready var lives_count = $MC/VB/MC/PL/MC/VB/HbOptions/Panel5/MC/VB/LivesCount
@onready var crosshairs = $MC/VB/MC/PL/MC/VB/HbOptions/Panel6/MC/VB/Crosshairs
@onready var added_cpus = $MC/VB/MC/PL/MC/VB/HbOptions/Panel7/MC/VB/AddiontalCpus


func update_settings() -> void:
	Blast.settings.map_size = map_sizes.selected
	Blast.settings.map_type = map_types.selected
	Blast.settings.rock_density = asteroid_count.selected
	Blast.settings.crate_density = crate_count.selected
	Blast.settings.lives_count = lives_count.selected
	Blast.settings.show_crosshairs = crosshairs.selected
	Blast.settings.added_cpus = added_cpus.selected
	if Blast.settings.map_type == 2 and Blast.settings.map_size < 4:
		Blast.settings.map_type = 0
		map_types.select( Blast.settings.map_type )
	elif Blast.settings.map_type == 1 and Blast.settings.map_size < 2:
		Blast.settings.map_type = 0
		map_types.select( Blast.settings.map_type )
	Blast.save_settings()
	update_ui_state()


func update_ui_state() -> void:
	if Blast.settings.map_size > 3:
		map_types.set_item_disabled( 1, false )
		map_types.set_item_disabled( 2, false )
	elif Blast.settings.map_size > 1:
		map_types.set_item_disabled( 1, false )
		map_types.set_item_disabled( 2, true )
	else:
		map_types.set_item_disabled( 1, true )
		map_types.set_item_disabled( 2, true )


func _ready() -> void:
	Engine.physics_ticks_per_second = 60
	MusicPlayer.play( 3 )
	Globals.is_menu_page = true
	map_sizes.select( Blast.settings.map_size )
	map_types.select( Blast.settings.map_type )
	asteroid_count.select( Blast.settings.rock_density )
	crate_count.select( Blast.settings.crate_density )
	lives_count.select( Blast.settings.lives_count )
	crosshairs.select( Blast.settings.show_crosshairs )
	added_cpus.select( Blast.settings.added_cpus )
	update_ui_state()


func _on_start_button_pressed() -> void:
	Blast.data.settings = Blast.settings
	Blast.data.is_tutorial = false
	get_tree().change_scene_to_packed( Blast.scenes.game )


func _on_tutorial_button_pressed() -> void:
	Blast.data.is_tutorial = true
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


func _on_crosshairs_item_selected( _index: int ) -> void:
	update_settings()


func _on_addiontal_cpus_item_selected( _index: int ) -> void:
	update_settings()


func _on_controls_button_pressed() -> void:
	var controls: Panel = $Controls
	var tween: Tween = create_tween()
	var controls_button: Button = $MC/VB/MC/PL/MC/VB/HbMainButtons/ControlsButton
	controls.modulate.a = 0
	controls.show()
	tween.tween_property( controls, "modulate:a", 1.0, 0.5 )
	controls_button.release_focus()
