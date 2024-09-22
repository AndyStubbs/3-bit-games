extends Control


@export var rows: int = 1
@export var cols: int = 2


var buff_x: float = 60
var buff_y: float = 250
var player_data: Dictionary
var container_width = 129
var container_height = 129
var img_foreground: Image
var foreground_texture: ImageTexture
var is_blinking: bool = false


@onready var tank: TUN_Tank = $View/SubViewportContainer/SubViewport/World/Tank
@onready var camera: Camera2D = $View/SubViewportContainer/SubViewport/World/Tank/Camera2D
@onready var ui: TUN_PlayerUI = $PlayerUi
@onready var static_texture = $View/StaticTexture
@onready var static_sound: AudioStreamPlayer = $StaticSound
@onready var minimap_container: Panel = $View/MiniMapContainer


func _ready() -> void:
	if rows == 0:
		rows = 1
		buff_x = 30
		buff_y = 45
		$PlayerUi.hide()
		$View/MiniMapContainer/MiniMap/Dot.hide()
	elif rows == 2:
		buff_x = 140
		buff_y = 20
		minimap_container.scale = Vector2( 1.5, 1.5 )
		minimap_container.position = Vector2( 320, 100 )
	elif cols == 3:
		buff_x = 35
	var win_size = get_window().content_scale_size
	var width: int = roundi( win_size.x / float( cols ) - buff_x )
	var height: int = roundi( win_size.y / float( rows ) - buff_y )
	$View/SubViewportContainer/SubViewport.size = Vector2i( width, height )
	$View.custom_minimum_size = Vector2i( width, height )
	@warning_ignore( "integer_division" )
	static_texture.size = Vector2i( roundi( width / 4 ) + 1, roundi( height / 4 ) + 1 )
	camera.zoom.x = Tun.ZOOM[ 0 ]
	camera.zoom.y = Tun.ZOOM[ 1 ]
	tank.init()
	ui.player_tank = tank
	
	# Add low energy blinking
	img_foreground = Image.create( container_width, container_height, false, Image.FORMAT_RGBA8 )
	img_foreground.fill_rect( Rect2i( 0, 0, container_width, container_height ), Color( 1, 1, 1, 0 ) )
	foreground_texture = ImageTexture.create_from_image( img_foreground )
	static_texture.texture = foreground_texture
	Tun.on_energy_changed.connect( on_energy_changed )


func on_energy_changed( changed_tank: TUN_Tank ) -> void:
	if is_blinking:
		return
	if changed_tank == tank and tank.energy < 30:
		static_sound.play()
		for i in range( 128 - ( tank.energy * 4.0 ) ):
			var y = randi_range( 0, container_height - 2 )
			var r = randf_range( 0, 1 )
			if r < 0.35:
				for x in range( container_width - 1 ):
					img_foreground.set_pixel( x, y, get_random_color() )
			elif r > 0.6:
				img_foreground.fill_rect( Rect2i( 0, y, container_width, 1 ), Color( 1, 1, 1, 0 ) )
		foreground_texture.update( img_foreground )
		static_texture.visible = true
		is_blinking = true
		var blink_time = min( ( 100.0 / ( tank.energy * 300 + 25 ) ) + 0.01, 0.3 )
		await get_tree().create_timer( blink_time ).timeout
		static_texture.visible = false
		#img_foreground.fill_rect( Rect2i( 0, 0, container_width, container_height ), Color( 1, 1, 1, 0 ) )
		#foreground_texture.update( img_foreground )
		await get_tree().create_timer( ( tank.energy * 4.0 ) / 100.0 ).timeout
		is_blinking = false


func get_random_color() -> Color:
	return Color( randf_range( 0, 1 ), randf_range( 0, 1 ), randf_range( 0, 1 ) )
