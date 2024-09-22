extends Node2D
class_name TUN_Tank


const BASE_SPEED: float = 1.0
const BULLET_SCENE = preload( "res://Games/TunnelTanks/Scenes/tun_bullet.tscn" )
const ACTION_BITS: Dictionary = {
	"is_action_pressed": {
		"Fire": 0,
		"Up": 1,
		"Right": 2,
		"Down": 3,
		"Left": 4,
		"UpLeft": 5,
		"UpRight": 6,
		"DownLeft": 7,
		"DownRight": 8
	},
	"is_action_just_released": {
		"Fire": 9,
		"Up": 10,
		"Right": 11,
		"Down": 12,
		"Left": 13
	}
}


var network_id: String = ""
var player_id: int = 0
var display_name: String = "Player 1"
var speed: int = 1
var controls: String = "P1"
var color1: Color = Color.WHITE
var color2: Color = Color.WHITE
var color3: Color = Color.WHITE
var is_blank: bool = false
var map_width: int = 0
var map_height: int = 0
var bases: Array = []
var base: Rect2i
var blocked_count: int = 0
var is_in_base: bool = false
var is_in_own_base: bool = false
var direction: String = "N"
var last_pos: Vector2
var is_gun_ready: bool = true
var delay_count: int = 0
var is_firing: bool = true
var clones: Array = []
var energy_drain_rate: float = 1.0
var energy_charge_rate: float = 6.0
var shield_charge_rate: float = 3.0
var shields: float = 100.0:
	set( value ):
		shields = clampf( value, 0, 100.0 )
		Tun.on_shields_changed.emit( self )
var energy: float = 100.0:
	set( value ):
		energy = clampf( value, 0, 100.0 )
		Tun.on_energy_changed.emit( self )
		if energy == 0:
			kill()
var score: int = 0:
	set( value ):
		score = value
		Tun.on_score_changed.emit( self )
var is_invulnerable: bool = false
var kills: int = 0
var killed: int = 0
var shots: int = 0
var hits: int = 0
var accuracy: float = 0
var meters_dug: int = 0
var meters_moved: int = 0
var is_alive: bool = false
var is_observer: bool = false
var is_winner: bool = false
var time_in_base: float = 0
var is_cpu: bool = false
var cpu_ai: TUN_CPU_AI
var remote_input: Dictionary = {
	"is_action_pressed": {
		"Fire": false,
		"Up": false,
		"Right": false,
		"Down": false,
		"Left": false,
		"UpLeft": false,
		"UpRight": false,
		"DownLeft": false,
		"DownRight": false
	},
	"is_action_just_released": {
		"Fire": false,
		"Up": false,
		"Right": false,
		"Down": false,
		"Left": false,
	}
}
var remote_action: int = 0:
	set( value ):
		remote_action = value
		remote_input = decode_from_int( remote_action )
var last_remote_action: int = 0


@onready var sprite = $Sprite2D
@onready var camera = $Camera2D
@onready var shield_sprite = $ShieldSprite
@onready var charge_sprite = $ChargeSprite


func _ready() -> void:
	if not is_blank:
		set_process( false )
		set_physics_process( false )
	else:
		charge_sprite.hide()
		shield_sprite.hide()


func init() -> void:
	if Tun.settings.SPEED == 2:
		speed = 2
	else:
		speed = 1
	if controls.begins_with( "J" ):
		remote_input.is_action_pressed.erase( "UpLeft" )
		remote_input.is_action_pressed.erase( "UpRight" )
		remote_input.is_action_pressed.erase( "DownLeft" )
		remote_input.is_action_pressed.erase( "DownRight" )
	
	if is_blank:
		is_alive = false
		$Sprite2D.hide()
		is_observer = true
		controls = "ANY"
		return
	
	if is_cpu:
		camera.queue_free()
	
	if is_cpu:
		cpu_ai = TUN_CPU_AI.new( self )
	
	is_alive = true
	
	var swap_colors: Array = [
		Color.BLACK,
		Color.WHITE,
		Color( 0.5, 0.5, 0.5 )
	]
	var base_colors: Array = [
		color1, color2, color3
	]
	var new_sprite_frames = SpriteFrames.new()
	for animation in sprite.sprite_frames.get_animation_names():
		var texture: Texture2D = sprite.sprite_frames.get_frame_texture( animation, 0 )
		var image = texture.get_image()
		for y in image.get_height():
			for x in image.get_width():
				var color: Color = image.get_pixel( x, y )
				if color.a != 0:
					for i in range( swap_colors.size() ):
						var sc = swap_colors[ i ]
						if Globals.are_colors_simular( sc, color ):
							image.set_pixel( x, y, base_colors[ i ] )
		var t2 = ImageTexture.create_from_image( image )
		new_sprite_frames.add_animation( animation )
		new_sprite_frames.add_frame( animation, t2 )
	sprite.sprite_frames = new_sprite_frames
	Tun.on_tank_ready.emit( self )


func _physics_process( delta ):
	if is_observer:
		process_observer()
		return
	if is_cpu:
		cpu_ai.process()
	
	process_weapons( delta )
	process_movement( delta )


func process_weapons( _delta: float ) -> void:
	if get_is_action_pressed( "Fire" ):
		is_firing = true
		if is_gun_ready:
			energy -= 1
			shots += 1
			var bullet: TUN_Bullet = BULLET_SCENE.instantiate()
			bullet.modulate = color2
			get_parent().add_child( bullet )
			bullet.fire( position, direction, self )
			is_gun_ready = false
			await get_tree().create_timer( 0.15 ).timeout
			is_gun_ready = true
	else:
		is_firing = false


func process_movement( delta: float ) -> void:
	is_invulnerable = false
	if delay_count > 0 and not is_firing:
		delay_count -= 1
		return
	
	if not is_cpu:
		update_remote_input_from_global_input()
	
	# Add a delay if moving diagnoal and an action is released
	if (
		( direction == "NE" or direction == "SE" or direction == "NW" or direction == "SW" ) and 
		(
			get_is_action_just_released( "Left" ) or
			get_is_action_just_released( "Right" ) or
			get_is_action_just_released( "Up" ) or
			get_is_action_just_released( "Down" )
		)
	):
		return
	
	var move_direction = get_move_direction()
	move( move_direction, delta )


func process_observer() -> void:
	var move_direction = get_move_direction()
	move_observer( move_direction )


func reset() -> void:
	set_process( true )
	set_physics_process( true )
	modulate.a = 1.0
	direction = "N"
	sprite.play( "N" )
	is_alive = true
	is_observer = false
	energy = 100.0
	shields = 100.0
	for clone in clones:
		clone.modulate.a = 1.0
	update_clones()


func update_remote_input_from_global_input():
	
	# Update action_pressed
	for key in remote_input.is_action_pressed.keys():
		var action_name = key + "_" + controls
		remote_input.is_action_pressed[ key ] = Input.is_action_pressed( action_name )
	
	# Update action_just_released
	for key in remote_input.is_action_pressed.keys():
		var action_name = key + "_" + controls
		remote_input.is_action_just_released[ key ] = Input.is_action_just_released( action_name )
	
	remote_action = encode_to_int( remote_input )


func move( move_direction: String, delta: float ) -> void:
	var move_vector = get_move_vector( move_direction )
	if move_direction != "":
		direction = move_direction
	sprite.play( direction )
	if not move_vector.is_zero_approx():
		for i in range( speed ):
			last_pos = position
			position += move_vector
			Tun.on_tank_moved.emit( self )
	update_clones()
	var tank_rect := Rect2i(
		Vector2i( roundi( position.x + 4 ), roundi( position.y + 4 ) ),
		Vector2i( 1, 1 )
	)
	is_in_own_base = base.encloses( tank_rect )
	is_in_base = false
	for other_base: Rect2i in bases:
		if other_base.encloses( tank_rect ):
			is_in_base = true
			continue
	
	var show_charge: bool = false
	var show_shield: bool = false
	if is_in_own_base:
		shields += delta * shield_charge_rate
		energy += delta * energy_charge_rate
		time_in_base += delta
		if energy < 100.0:
			show_charge = true
		if shields < 100.0:
			show_shield = true
	elif is_in_base:
		energy += delta * ( energy_charge_rate / 2.0 )
		if energy < 100.0:
			show_charge = true
	else:
		energy -= delta * energy_drain_rate
	if show_charge and show_shield:
		charge_sprite.position.x = 1.0
		charge_sprite.show()
		shield_sprite.position.x = 8.0
		shield_sprite.show()
	elif show_charge:
		charge_sprite.position.x = 4.5
		charge_sprite.show()
		shield_sprite.hide()
	elif show_shield:
		charge_sprite.hide()
		shield_sprite.position.x = 4.5
		shield_sprite.show()
	else:
		charge_sprite.hide()
		shield_sprite.hide()
	last_remote_action = remote_action


func move_observer( move_direction: String ) -> void:
	var move_vector = get_move_vector( move_direction )
	if not move_vector.is_zero_approx():
		for i in range( speed ):
			position += move_vector
			position.x = clampf( position.x, 0, map_width )
			position.y = clampf( position.y, 0, map_height )


func get_move_direction() -> String:
	var move_direction = ""
	if get_is_action_pressed( "Up" ):
		if get_is_action_pressed( "Left" ):
			move_direction = "NW"
		elif get_is_action_pressed( "Right" ):
			move_direction = "NE"
		else:
			move_direction = "N"
	elif get_is_action_pressed( "Down" ):
		if get_is_action_pressed( "Left" ):
			move_direction = "SW"
		elif get_is_action_pressed( "Right" ):
			move_direction = "SE"
		else:
			move_direction = "S"
	elif get_is_action_pressed( "Left" ):
		move_direction = "W"
	elif get_is_action_pressed( "Right" ):
		move_direction = "E"
	elif not controls.begins_with( "J" ):
		if get_is_action_pressed( "UpLeft" ):
			move_direction = "NW"
		elif get_is_action_pressed( "UpRight" ):
			move_direction = "NE"
		elif get_is_action_pressed( "DownLeft" ):
			move_direction = "SW"
		elif get_is_action_pressed( "DownRight" ):
			move_direction = "SE"
	
	return move_direction


func get_move_vector( current_direction: String ) -> Vector2:
	var move_vector: Vector2 = Vector2.ZERO
	if current_direction == "N":
		move_vector.y = -1
	elif current_direction == "S":
		move_vector.y = 1
	elif current_direction == "W":
		move_vector.x = -1
	elif current_direction == "E":
		move_vector.x = 1
	elif current_direction == "NE":
		move_vector.x = 1
		move_vector.y = -1
	elif current_direction == "NW":
		move_vector.x = -1
		move_vector.y = -1
	elif current_direction == "SE":
		move_vector.x = 1
		move_vector.y = 1
	elif current_direction == "SW":
		move_vector.x = -1
		move_vector.y = 1
	
	return move_vector


func create_clone() -> AnimatedSprite2D:
	var clone = AnimatedSprite2D.new()
	clone.z_index = 1
	clone.centered = sprite.centered
	clone.sprite_frames = sprite.sprite_frames
	clone.offset = sprite.offset
	clone.position = position
	
	var label: Label = Label.new()
	label.text = str( energy )
	label.label_settings = LabelSettings.new()
	label.label_settings.font_size = 8
	label.modulate.a = 0
	clone.add_child( label )
	clones.append( clone )
	return clone


func update_clones() -> void:
	for clone in clones:
		clone.play( direction )
		clone.position = position
		if is_in_own_base:
			clone.get_child( 0 ).text = "*%d" % energy
		else:
			clone.get_child( 0 ).text = "%d" % energy


func hit( bullet: TUN_Bullet ) -> void:
	if is_invulnerable:
		return
	bullet.tank.hits += 1
	shields -= bullet.damage
	is_invulnerable = true
	if shields == 0:
		killed += 1
		bullet.tank.kills += 1
		kill()


func kill() -> void:
	if not is_alive:
		return
	if cpu_ai != null:
		cpu_ai.reset()
	is_alive = false
	is_observer = true
	modulate.a = 0
	for clone in clones:
		clone.modulate.a = 0
	Tun.on_tank_destroyed.emit( self )


func get_is_action_pressed( action_name ) -> bool:
	if is_cpu:
		return remote_input.is_action_pressed[ action_name ]
	return Input.is_action_pressed( action_name + "_" + controls )


func get_is_action_just_released( action_name ) -> bool:
	if is_cpu:
		return remote_input.is_action_just_released[ action_name ]
	return Input.is_action_just_released( action_name + "_" + controls )


func encode_to_int( input: Dictionary ) -> int:
	var result: int = 0
	var bit: int = 0
	
	for action_name in input.is_action_pressed.keys():
		if input.is_action_pressed[ action_name ]:
			result |= ( 1 << bit )
		bit += 1
	
	for action_name in input.is_action_just_released.keys():
		if input.is_action_just_released[ action_name ]:
			result |= ( 1 << bit )
		bit += 1
	
	return result


func decode_from_int( encoded: int ) -> Dictionary:
	var result: Dictionary = {
		"is_action_pressed": {},
		"is_action_just_released": {}
	}
	var bit: int = 0
	for action_name in remote_input.is_action_pressed.keys():
		var is_set: bool = ( encoded & ( 1 << bit ) ) != 0
		result.is_action_pressed[ action_name ] = is_set
		bit += 1
	
	for action_name in remote_input.is_action_just_released.keys():
		var is_set: bool = ( encoded & ( 1 << bit ) ) != 0
		result.is_action_just_released[ action_name ] = is_set
		bit += 1
	
	return result
