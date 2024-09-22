extends Control


enum GAMES { RAF, TUN, BLAST }


const START_ALPHA = 0.5
const FULL_ALPHA = 1.0


@export var game: GAMES = GAMES.RAF


var games: Dictionary = {
	GAMES.RAF: {
		"image": load( "res://Assets/Images/ram_game_image.webp" ),
		"title": "TR_RAF_TITLE",
		"scene": load( "res://Games/ReadyAimFire/Scenes/menu.tscn" ),
	},
	GAMES.TUN: {
		"image": load( "res://Assets/Images/tun_game_image.webp" ),
		"title": "TR_TUNNEL_TANKS",
		"scene": load( "res://Games/TunnelTanks/Scenes/tun_menu.tscn" ),
	},
	GAMES.BLAST: {
		#"image": load( "res://Assets/Images/blast_game_image.webp" ),
		"image": load( "res://Assets/Images/space_oval_shape.png" ),
		"title": "Blastroids",
		"scene": load( "res://Games/Blastroids/Scenes/blast_menu.tscn" ),
	}
}
var is_hovered: bool = false


func _ready() -> void:
	$TextureRect.texture = games[ game ].image
	$Label.text = tr( games[ game ].title )
	modulate.a = START_ALPHA
	Globals.on_language_changed.connect( on_language_changed )


func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property( self, "modulate:a", FULL_ALPHA, 0.25 )
	is_hovered = true


func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property( self, "modulate:a", START_ALPHA, 0.25 )
	is_hovered = false


func _input( _event: InputEvent ) -> void:
	if Input.is_action_just_pressed( "Click" ):
		if is_hovered:
			var scene = games[ game ].scene
			get_tree().change_scene_to_packed( scene )


func _on_focus_entered() -> void:
	var tween = create_tween()
	tween.tween_property( self, "modulate:a", FULL_ALPHA, 0.25 )


func _on_focus_exited() -> void:
	var tween = create_tween()
	tween.tween_property( self, "modulate:a", START_ALPHA, 0.25 )


func on_language_changed() -> void:
	$Label.text = tr( games[ game ].title )
