extends Node


var scenes: Dictionary = {
	"menu": load( "res://Games/Blastroids/Scenes/blast_menu.tscn" ),
	"game": load( "res://Games/Blastroids/Scenes/blast_game.tscn" )
}

var rock_names: Dictionary
var settings: Dictionary = {
	"rock_density": 0.025,
	#"rock_density": 0.001,
	"rect": Rect2( -5000, -5000, 10000, 10000 ),
	"lives": 3
}


func set_camera_limits( camera: Camera2D, buffer: int ) -> void:
	var rect: Rect2 = settings.rect
	camera.limit_left = roundi( rect.position.x ) + buffer
	camera.limit_right = roundi( rect.position.x + rect.size.x ) #- roundi( float( buffer ) / 2 )
	camera.limit_top = roundi( rect.position.y ) + buffer
	camera.limit_bottom = roundi( rect.position.y + rect.size.y ) - buffer


func _ready() -> void:
	var file_name = "res://Games/Blastroids/Rocks/rocks.json"
	var load_file = FileAccess.open( file_name, FileAccess.READ )
	var json_string = load_file.get_as_text()
	rock_names = JSON.parse_string( json_string )
