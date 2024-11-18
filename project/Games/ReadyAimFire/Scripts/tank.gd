extends Node2D
class_name RAF_Tank


const BB_SCENE: PackedScene = preload( "res://Games/ReadyAimFire/Scenes/bouncing_bullet.tscn" )
const BULLET_SCENE: PackedScene = preload( "res://Games/ReadyAimFire/Scenes/bullet.tscn" )
const POINTS_SCENE: PackedScene = preload( "res://Games/ReadyAimFire/Scenes/points.tscn" )
const EXPLOSION_SCENE = preload( "res://Games/ReadyAimFire/Scenes/explosion.tscn" )
const SWAP_COLORS: Array = [
	Color.BLACK,
	Color.WHITE,
	Color( 0.5, 0.5, 0.5 )
]
const CANNON_ROT: Dictionary = {
	"RIGHT_MIN": -1.2,
	"RIGHT_MAX": 0.25,
	"LEFT_MIN": -0.25,
	"LEFT_MAX": 1.2,
}
const MIN_POWER: float = 250
const MAX_POWER: float = 1500
const FADE_DURATION: float = 0.5
const FLY_POINTS: float = 2.0
const BUFF_X: float = 140


@export var controls: String = "ANY"
@export var is_facing_left: bool = false:
	set( value ):
		is_facing_left = value
		set_tank_flipped()
@export var movement_points: int = 10
@export var display_name: String = "Player 1"


var player_id: int = 0
var level: RAF_Level
var colors: Array = [
	Color( 0.0, 0.0, 0.1 ), Color( 0.2, 0.2, 0.9 ), Color( 0.3, 0.6, 0.8 )
]
var tank_width: float = 18
var tank_height: float = 9
var tank_radius: float = 9
var tank_radius_square: float = tank_radius * tank_radius
var turn: int = 0
var is_turn: bool = false
var is_firing: bool = false
var can_fire: bool = false
var fire_power: float = 0:
	set( value ):
		var pb: ProgressBar = $PowerBar
		var cb: ColorRect = $PowerBar/CurrentBar
		pb.value = value * 100
		cb.position.x = value * pb.size.x
		fire_power = value
var booster_power: float = 1
var fd: float = 0.25
var target_rotation: float
var is_body_rotating: bool = false
var is_grounded: bool = true
var velocity: Vector2 = Vector2.ZERO
var mass: float = 1.0
var movement_points_remaining: float:
	set( value ):
		movement_points_remaining = value
		movement_label.text = "%d" % ceili( movement_points_remaining )
		if movement_points_remaining <= 0:
			set_rocket_boost_bullet_select( true )
var score_label: Label
var score: int = 0:
	set( value ):
		score = value
		if score_label != null:
			if score < 0:
				score_label.modulate = Color.RED
			else:
				score_label.modulate = Color.WHITE
			score_label.text = str( score )
var score_label_count: int = 0
var fade_tween: Tween
var is_fading_out: bool = false
var is_fading_in: bool = false
var slime_count: int = 0
var is_waiting_for_slime_count: bool = false
var ground_points: Array
var bullet_type: Raf.BULLET_TYPES
var laser_length: float = 0
var laser_pos: Vector2
var can_drive: bool = false
var rotate_count: int = 0
var is_booster_mode: bool = false
var is_booster_activated: bool = false
var is_boosting: bool = false
var potion_effect: int = 0
var last_bullet_removed_time: float = 0
var cpu_ai: RAF_CPU_AI
var is_cpu: bool = false


@onready var anim: AnimatedSprite2D = $Body/Anim
@onready var cannon: Sprite2D = $Body/Anim/Cannon
@onready var fire_point: Marker2D = $Body/Anim/Cannon/Marker2D
@onready var target_point: Sprite2D = $Body/Anim/Cannon/Target
@onready var movement_label: Label = $MovementLabel
@onready var bullet_image: Sprite2D = $BulletImage
@onready var bullet_select: ItemList = $BulletSelect
@onready var angle_label: Label = $AngleLabel
@onready var engine_sound: AudioStreamPlayer = $EngineSound
@onready var fire_sound: AudioStreamPlayer = $FireSound
@onready var muzzle_fire: GPUParticles2D = $Body/Anim/Cannon/Marker2D/MuzzleFireRight
@onready var rotate_sound: AudioStreamPlayer = $RotateSound
@onready var charge_sound: AudioStreamPlayer = $ChargeSound
@onready var body: Node2D = $Body
@onready var spots: Node2D = $Spots
@onready var laser: Line2D = $Body/Anim/Cannon/Laser
@onready var booster1: AnimatedSprite2D = $Body/Boosters/Booster1
@onready var booster2: AnimatedSprite2D = $Body/Boosters/Booster2


func _ready() -> void:
	if not Raf.is_easy_targeting:
		for spot in $Spots.get_children():
			spot.modulate.a = 0
		$Spots.get_child( 0 ).modulate.a = 1
		$Spots.get_child( 1 ).modulate.a = 1
		$Spots.get_child( 2 ).modulate.a = 1
		$Spots.get_child( 3 ).modulate.a = 1
		$Spots.get_child( 4 ).modulate.a = 1
	
	tank_width = $Body/Ground/Ground0.position.distance_to( $Body/Ground/Ground8.position )
	for gp in $Body/Ground.get_children():
		ground_points.append( gp )
	cannon.self_modulate = colors[ 2 ]
	if is_facing_left:
		muzzle_fire = $Body/Anim/Cannon/Marker2D/MuzzleFireLeft
	else:
		muzzle_fire = $Body/Anim/Cannon/Marker2D/MuzzleFireRight
	set_tank_flipped()
	set_tank_colors()


func _physics_process( delta: float ) -> void:
	if is_turn and controls == "CPU":
		cpu_ai.process( delta )
	rotate_tank_angle( delta )
	if is_grounded:
		if is_turn and can_drive:
			drive_tank( delta )
	else:
		if is_turn and can_drive and is_booster_mode:
			fly_tank( delta )
		set_tank_position( position + velocity * delta )
		velocity += level.gravity
		set_tank_grounded()


func init( new_level: RAF_Level, new_score_label: Label ) -> void:
	score_label = new_score_label
	movement_points_remaining = movement_points
	level = new_level
	level.on_explosion.connect( on_explosion )
	level.on_heights_updated.connect( on_heights_updated )
	tank_radius = ( ( tank_width / 2 ) * anim.scale.x ) / level.scale
	tank_radius_square = tank_radius * tank_radius
	init_bullets()
	set_tank_on_hill()
	hide_ui( true )
	if controls == "CPU":
		cpu_ai = RAF_CPU_AI.new()
		cpu_ai.init( self )
		is_cpu = true


func init_bullets() -> void:
	
	# Get bullet counts
	var bullets: Dictionary = {}
	for i in range( level.ammo.size() ):
		var bt = level.ammo [ i ]
		if bullets.has( bt ):
			bullets[ bt ] += 1
		else:
			bullets[ bt ] = 1
	
	# Update bullet select
	for bt in bullets.keys():
		var data = Raf.bullet_data[ bt ]
		var count = bullets[ bt ]
		if count > 0:
			var item_text = "%s (%s)" % [ data.text, count ]
			bullet_select.add_item( item_text, data.ui_image )
			bullet_select.set_item_metadata(
				bullet_select.item_count - 1,
				[ bt, count ]
			)
	
	# Update bullet select height
	update_bullet_select_height()
	
	# Update bullets
	bullet_select.select( 0 )
	set_bullet_type()
	update_bullet_image()


func begin_turn() -> void:
	if not is_grounded:
		await get_tree().create_timer( 0.25 ).timeout
		begin_turn()
		return
	target_point.show()
	if is_cpu:
		cpu_ai.begin_turn()
	is_booster_activated = false
	set_bullet_type()
	is_turn = true
	can_drive = true
	turn += 1
	potion_effect -= 1
	can_fire = true
	var pb: ProgressBar = $PowerBar
	fire_power = 0
	movement_points_remaining = movement_points
	set_rocket_boost_bullet_select( false )
	var tween = create_tween()
	tween.set_parallel( true )
	tween.tween_property( bullet_image, "modulate:a", 1.0, 0.5 )
	tween.tween_property( pb, "modulate:a", 1.0, 0.5 )
	tween.tween_property( angle_label, "modulate:a", 1.0, 0.5 )
	tween.tween_property( movement_label, "modulate:a", 1.0, 0.5 )
	fade_in_bullet_select()
	calc_slime_penalty( 15, 3 )
	update_bullet_image()
	apply_potion_effect()


func hide_ui( is_instant: bool = false) -> void:
	target_point.hide()
	update_bullet_image()
	if engine_sound.playing:
		engine_sound.stop()
	if fire_sound.playing:
		fire_sound.stop()
	if rotate_sound.playing:
		rotate_sound.stop()
	if charge_sound.playing:
		charge_sound.stop()
	anim.play( "idle" )
	is_turn = false
	var pb: ProgressBar = $PowerBar
	var lb: ColorRect = $PowerBar/LastBar
	lb.position.x = fire_power * pb.size.x
	if is_instant:
		bullet_image.modulate.a = 0
		pb.modulate.a = 0
		angle_label.modulate.a = 0
		movement_label.modulate.a = 0
		bullet_select.modulate.a = 0
	else:
		var tween = create_tween()
		tween.set_parallel( true )
		tween.tween_property( bullet_image, "modulate:a", 0, 0.5 )
		tween.tween_property( pb, "modulate:a", 0, 0.5 )
		tween.tween_property( angle_label, "modulate:a", 0, 0.5 )
		tween.tween_property( movement_label, "modulate:a", 0, 0.5 )
		fade_out_bullet_select()
	$Body/Boosters.hide()


func on_explosion( explosion: RAF_Explosion ) -> void:
	await get_tree().create_timer( 0.15 ).timeout
	var point: Vector2 = explosion.position
	var force: float = explosion.force
	var radius: float = explosion.radius * level.scale
	var expl_points: int = explosion.points
	var fired_from: RAF_Tank = explosion.fired_from
	var is_direct_hit: bool = false
	if explosion.hits.has( self ):
		is_direct_hit = true
	var tank_radius_big = tank_radius * 1.5
	var distance = maxf( position.distance_to( point ), tank_radius_big + 1 )
	distance -= tank_radius_big
	if distance > radius and not is_direct_hit:
		return
	if explosion.is_potion:
		potion_effect = 6
		apply_potion_effect()
		return
	var points_awarded: int
	var hit_pct: float
	if is_direct_hit:
		points_awarded = expl_points
		hit_pct = 1
	else:
		hit_pct = ( radius - distance ) / radius
	points_awarded = clampi(
		ceili( float( expl_points ) * hit_pct ),
		1,
		expl_points
	)
	
	# Add impact - make sure not under ground
	if can_move( -1 ) or can_move( 1 ):
		is_grounded = false
		var upward_bias = Vector2( 0, -tank_radius_big )
		var impact_point = position - point + upward_bias
		var direction = ( impact_point ).normalized()
		var impact_magnitude = force * hit_pct
		var impact_force = direction * impact_magnitude
		velocity = impact_force / mass
		if velocity.y < -2500:
			velocity.y = -2500
	if fired_from == null:
		fired_from = self
	
	# Update Score
	if fired_from == self:
		points_awarded *= -1
	
	add_points( points_awarded, point, fired_from )


func add_points( points_awarded: int, point: Vector2, target: RAF_Tank ) -> void:
	level.scores.append( [ target.player_id, points_awarded ] )
	var label: Label = POINTS_SCENE.instantiate()
	label.score = points_awarded
	label.tank = target
	var window_x = get_viewport_rect().size.x
	var ratio_x = point.x / ( level.width * level.scale )
	var x = ratio_x * window_x
	var y = point.y
	label.start_pos = Vector2( x, y )
	label.offset = Vector2(
		target.score_label.global_position.x + target.score_label.size.x,
		target.score_label.global_position.y
	)
	if points_awarded > 0:
		label.text = "+" + str( points_awarded )
	else:
		label.text = str( points_awarded )
	target.score_label.get_parent().get_parent().get_parent().add_child( label )
	label.init( level )


func apply_potion_effect() -> void:
	var target = $Body/Anim/Cannon/Target
	if potion_effect == 6:
		await get_tree().create_timer( 1.5 ).timeout
		$Body/Ground.scale = Vector2( 3, 3 )
		$Potion2Sound.play()
		laser.scale = Vector2( 2.0 / 6, 2.0 / 6 )
		var tween = create_tween()
		tween.set_parallel( true )
		tween.set_trans( Tween.TRANS_BOUNCE )
		tween.tween_property( anim, "scale", Vector2( 6, 6 ), 1.5 )
		tween.tween_property( target, "scale", Vector2( 2.0 / 6, 2.0 / 6 ), 1.5 )
		tween.tween_property( $Body/Boosters, "scale", Vector2( 3, 3 ), 1.5 )
		tween.tween_property( body, "position:y", -25, 1.5 )
		await tween.finished
		tank_radius = ( ( tank_width / 2 ) * anim.scale.x ) / level.scale
		tank_radius_square = tank_radius * tank_radius
		set_collision_shape()
	elif potion_effect == 4:
		$Body/Ground.scale = Vector2( 2, 2 )
		$Body/Boosters.scale = Vector2( 2, 2 )
		$PotionSound.play()
		laser.scale = Vector2( 0.5, 0.5 )
		var tween = create_tween()
		tween.set_parallel( true )
		tween.set_trans( Tween.TRANS_BOUNCE )
		tween.tween_property( anim, "scale", Vector2( 4, 4 ), 0.75 )
		tween.tween_property( target, "scale", Vector2( 0.5, 0.5 ), 1.5 )
		tween.tween_property( body, "position:y", -12.5, 1.5 )
		tank_radius = ( ( tank_width / 2 ) * anim.scale.x ) / level.scale
		tank_radius_square = tank_radius * tank_radius
		await tween.finished
		set_collision_shape()
	elif potion_effect == 2:
		$Body/Ground.scale = Vector2( 1, 1 )
		$Body/Boosters.scale = Vector2( 1, 1 )
		$PotionSound.play()
		laser.scale = Vector2( 1, 1 )
		var tween = create_tween()
		tween.set_parallel( true )
		tween.set_trans( Tween.TRANS_BOUNCE )
		tween.tween_property( anim, "scale", Vector2( 2, 2 ), 0.75 )
		tween.tween_property( target, "scale", Vector2( 1, 1 ), 1.5 )
		tween.tween_property( body, "position:y", 0, 1.5 )
		await tween.finished
		tank_radius = ( ( tank_width / 2 ) * anim.scale.x ) / level.scale
		tank_radius_square = tank_radius * tank_radius
		set_collision_shape()


func on_heights_updated() -> void:
	if can_move( -1 ) or can_move( 1 ):
		is_grounded = false


func drive_tank( delta ) -> void:
	set_cannon_with_mouse()
	if get_input( "Flip_" + controls, true ):
		is_facing_left = !is_facing_left
		set_tank_flipped()
	process_bullet_select()
	apply_tank_movement( delta )
	update_cannon_angle( delta )
	if is_booster_mode:
		is_boosting = false
		control_boosters( delta )
		control_rocket_particles()
	else:
		control_cannon( delta )


func fly_tank( delta ) -> void:
	if rotate_sound.playing:
		rotate_sound.stop()
	is_boosting = false
	control_boosters( delta )
	if get_input( "Left_" + controls ):
		if movement_points_remaining > 0:
			var dx = -100 * delta
			if can_move( dx ):
				velocity.x += dx
				movement_points_remaining -= FLY_POINTS * delta
				if is_boosting:
					booster1.rotation = body.rotation - PI / 4
					booster2.rotation = body.rotation - PI / 4
				else:
					booster1.rotation = body.rotation - PI / 2
					booster2.rotation = body.rotation - PI / 2
				is_boosting = true
		elif not $WrongSound.playing:
			$WrongSound.play()
	elif get_input( "Right_" + controls ):
		if movement_points_remaining > 0:
			var dx = 100 * delta
			if can_move( dx ):
				velocity.x += dx
				movement_points_remaining -= FLY_POINTS * delta
				if is_boosting:
					booster1.rotation = body.rotation + PI / 4
					booster2.rotation = body.rotation + PI / 4
				else:
					booster1.rotation = body.rotation + PI / 2
					booster2.rotation = body.rotation + PI / 2
				is_boosting = true
		elif not $WrongSound.playing:
			$WrongSound.play()
	control_rocket_particles()


func process_bullet_select() -> void:
	if is_firing: return
	var is_toggled: bool = false
	if get_input( "ToggleUp_" + controls, true ):
		is_toggled = true
		var selected_items: Array = bullet_select.get_selected_items()
		if selected_items.size() == 0:
			printerr( "Unable to toggle bullet (%s)" % bullet_select.item_count )
			return
		var selected_index = selected_items[ 0 ]
		selected_index -= 1
		if selected_index < 0:
			selected_index = bullet_select.item_count - 1
		if bullet_select.is_item_disabled( selected_index ):
			selected_index -= 1
			if selected_index < 0:
				selected_index = bullet_select.item_count - 1
		bullet_select.select( selected_index )
		update_bullet_image()
	if get_input( "ToggleDown_" + controls, true ):
		is_toggled = true
		var selected_items: Array = bullet_select.get_selected_items()
		if selected_items.size() == 0:
			printerr( "Unable to toggle bullet (%s)" % bullet_select.item_count )
			return
		var selected_index = selected_items[ 0 ]
		selected_index += 1
		if selected_index >= bullet_select.item_count:
			selected_index = 0
		if bullet_select.is_item_disabled( selected_index ):
			selected_index += 1
			if selected_index >= bullet_select.item_count:
				selected_index = 0
		bullet_select.select( selected_index )
		update_bullet_image()
	if is_toggled:
		$SelectBulletSound.play()
		set_bullet_type()
		fade_in_bullet_select()
	else:
		fade_out_bullet_select()


func fade_in_bullet_select() -> void:
	if not is_fading_in:
		if fade_tween != null and fade_tween.is_running():
			fade_tween.stop()
			is_fading_in = false
			is_fading_out = false
		var duration = FADE_DURATION * ( 1.0 - bullet_select.modulate.a )
		if duration > 0:
			is_fading_in = true
			fade_tween = create_tween()
			fade_tween.tween_property( bullet_select, "modulate:a", 1, duration )
			await fade_tween.finished
			is_fading_in = false


func fade_out_bullet_select() -> void:
	if not is_fading_out and not is_fading_in:
		if fade_tween != null and fade_tween.is_running():
			fade_tween.stop()
			is_fading_in = false
			is_fading_out = false
		if is_fading_in:
			return
		var duration = FADE_DURATION * bullet_select.modulate.a
		if duration > 0:
			is_fading_out = true
			fade_tween = create_tween()
			fade_tween.tween_property(
				bullet_select, "modulate:a", bullet_select.modulate.a, duration * 2
			)
			fade_tween.tween_property( bullet_select, "modulate:a", 0, duration )
			await fade_tween.finished
			is_fading_out = false


func remove_current_bullet() -> void:
	if Raf.is_tutorial:
		return
	if Time.get_ticks_msec() < last_bullet_removed_time + 1000:
		printerr( "Remove current bullet bug... (%s)" % bullet_select.item_count )
		return
	last_bullet_removed_time = Time.get_ticks_msec()
	var selected_items = bullet_select.get_selected_items()
	if selected_items.size() == 0:
		printerr( "Removing a bullet that doesn't exist (%s)" % bullet_select.item_count )
		return
	var selected_index = selected_items[ 0 ]
	var bullet_data = bullet_select.get_item_metadata( selected_index )
	bullet_data[ 1 ] -= 1
	if bullet_data[ 1 ] < 1:
		bullet_select.remove_item( selected_index )
		if bullet_select.item_count == 0:
			return
		if selected_index > bullet_select.item_count - 1:
			selected_index -= 1
		if bullet_select.is_item_disabled( selected_index ):
			bullet_select.set_item_disabled( selected_index, false )
		bullet_select.select( selected_index )
		update_bullet_select_height()
	else:
		bullet_select.set_item_metadata( selected_index, bullet_data )
		var new_text = bullet_select.get_item_text( selected_index )
		new_text = new_text.substr( 0, new_text.find( "(" ) )
		new_text += "(%s)" % bullet_data[ 1 ]
		bullet_select.set_item_text( selected_index, new_text )


func update_bullet_image() -> void:
	var selected_items = bullet_select.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[ 0 ]
		var bt = bullet_select.get_item_metadata( selected_index )[ 0 ]
		var bullet_data = Raf.bullet_data[ bt ]
		bullet_image.texture = bullet_data.ui_image
		var scroll: VScrollBar = bullet_select.get_v_scroll_bar()
		scroll.value = selected_index * 38 - 50
		switch_to_booster_mode( bullet_data.type == "booster" )


func update_booster_angles() -> void:
	booster1.rotation = -body.rotation
	booster2.rotation = -body.rotation


func switch_to_booster_mode( new_is_booster_mode: bool ) -> void:
	is_booster_mode = new_is_booster_mode
	if is_booster_mode:
		$Body/Boosters.show()
	else:
		$Body/Boosters.hide()


func update_bullet_select_height() -> void:
	bullet_select.size.y = clampf( 2 + bullet_select.item_count * 38, 45, 150 )
	bullet_select.position.y = -50 - bullet_select.size.y


func set_rocket_boost_bullet_select( is_disabled: bool ) -> void:
	for i in range( bullet_select.item_count ):
		if bullet_select.get_item_text( i ).begins_with( "Rocket Boost" ):
			bullet_select.set_item_disabled( i, is_disabled )


func apply_tank_movement( delta ) -> void:
	if movement_points_remaining <= 0:
		engine_sound.stop()
		anim.play( "idle" )
	var is_moving = false
	#if Input.is_action_pressed( "Left_" + controls ):
	if get_input( "Left_" + controls ):
		if movement_points_remaining > 0:
			var dx = -100 * delta
			if can_move( dx ):
				is_moving = true
				set_tank_position( position + Vector2( dx, 0 ) )
				calc_slime_penalty()
		elif not $WrongSound.playing:
			$WrongSound.play()
	#elif Input.is_action_pressed( "Right_" + controls ):
	elif get_input( "Right_" + controls ):
		if movement_points_remaining > 0:
			var dx = 100 * delta
			if can_move( dx ):
				is_moving = true
				set_tank_position( position + Vector2( dx, 0 ) )
				calc_slime_penalty()
		elif not $WrongSound.playing:
			$WrongSound.play()
	if is_moving:
		set_tank_on_hill()
		anim.play( "move" )
		if not engine_sound.playing:
			engine_sound.play()
	else:
		anim.play( "idle" )
		if engine_sound.playing:
			engine_sound.stop()


func update_cannon_angle( delta ) -> void:
	var factor: float = 1
	var new_rotation: float = cannon.rotation
	if Raf.bullet_data[ bullet_type ].type == "laser":
		if rotate_count < 10:
			factor = 0.15
		elif rotate_count < 15:
			factor = 0.25
		elif rotate_count < 30:
			factor = 0.5
		elif rotate_count < 50:
			factor = 0.75
		else:
			factor = 1
	#if Input.is_action_pressed( "Up_" + controls ):
	if get_input( "Up_" + controls ):
		rotate_count += 1
		if anim.flip_h:
			new_rotation = cannon.rotation + factor * delta
		else:
			new_rotation = cannon.rotation - factor * delta
	#elif Input.is_action_pressed( "Down_" + controls ):
	elif get_input( "Down_" + controls ):
		rotate_count += 1
		if anim.flip_h:
			new_rotation = cannon.rotation - factor * delta
		else:
			new_rotation = cannon.rotation + factor * delta
	else:
		rotate_count = 0
	set_cannon_rotation( new_rotation )


func set_cannon_with_mouse() -> void:
	if is_cpu:
		return
	if Input.is_action_pressed( "MouseDown" ):
		var mouse_pos = get_viewport().get_mouse_position()
		var angle = cannon.global_position.angle_to_point( mouse_pos ) - body.rotation
		if anim.flip_h:
			angle += PI
			if angle > PI:
				angle -= TAU
		set_cannon_rotation( angle )


func set_cannon_rotation( new_rotation: float ) -> void:
	var is_rotating: bool = false
	if new_rotation != cannon.rotation:
		var dir
		if anim.flip_h:
			dir = "LEFT_"
		else:
			dir = "RIGHT_"
		var min_rot = CANNON_ROT[ dir + "MIN" ]
		var max_rot = CANNON_ROT[ dir + "MAX" ]
		if new_rotation >= min_rot and new_rotation <= max_rot:
			is_rotating = true
		cannon.rotation = clampf( new_rotation, min_rot, max_rot )
	if is_rotating:
		if not rotate_sound.playing:
			rotate_sound.play()
	else:
		if rotate_sound.playing:
			rotate_sound.stop()
	var deg: float
	if anim.flip_h:
		deg = rad_to_deg( body.rotation + cannon.rotation )
	else:
		deg = rad_to_deg( ( body.rotation + cannon.rotation ) * -1 )
	angle_label.text = "%d°" % deg


func rotate_tank_angle( delta ) -> void:
	body.rotation = lerpf( body.rotation, target_rotation, 10.0 * delta )
	var diff = angle_difference( body.rotation, target_rotation )
	if abs( diff ) < 0.001:
		body.rotation = target_rotation
		is_body_rotating = false
	else:
		is_body_rotating = true
	update_booster_angles()


func control_cannon( delta ) -> void:
	if can_fire and get_input( "Fire_" + controls, true ):
		can_fire = false
		is_firing = true
		fire_power = 0
		charge_sound.play()
		show_spots()
	elif is_firing and get_input( "Fire_" + controls ):
		fire_power = clampf( fire_power + fd * delta, 0.01, 1.0 )
		if fire_power >= 1.0 || fire_power <= 0.01:
			fd *= -1
		set_marker_points( delta )
	if is_firing and get_input( "Fire_" + controls, false, true ):
		if rotate_sound.playing:
			rotate_sound.stop()
		hide_spots()
		charge_sound.stop()
		is_firing = false
		if Raf.bullet_data[ bullet_type ].type == "laser":
			fire_laser()
		else:
			fire_bullet()
		remove_current_bullet()
		can_drive = false


func control_boosters( delta ) -> void:
	if get_input( "Fire_" + controls ):
		if movement_points_remaining > 0:
			engine_sound.stop()
			anim.play( "idle" )
			is_booster_activated = true
			is_boosting = true
			target_rotation = 0
			if is_grounded:
				velocity.y = -240
			else:
				velocity.y -= 750 * delta
			is_grounded = false
			movement_points_remaining -= FLY_POINTS * delta
		else:
			if bullet_select.item_count == 1:
				end_booster()
			if not $WrongSound.playing:
				$WrongSound.play()


func control_rocket_particles() -> void:
	if is_boosting:
		if booster1.animation == "idle":
			booster1.play( "boost_up" )
			booster2.play( "boost_up" )
			await booster1.animation_finished
			booster1.play( "boost" )
			booster2.play( "boost" )
		if not $RocketSound.playing:
			$RocketSound.play()
	else:
		if booster1.animation == "boost" or booster1.animation == "boost_up":
			booster1.play( "boost_down" )
			booster2.play( "boost_down" )
			await booster1.animation_finished
			booster1.play( "idle" )
			booster2.play( "idle" )
		if $RocketSound.playing:
			$RocketSound.stop()


func fire_bullet() -> void:
	fire_sound.play()
	muzzle_fire.emitting = true
	var bullet_rotation: float = get_bullet_rotation()
	var power: float = get_bullet_power( fire_power )
	var bullet
	if bullet_type == Raf.BULLET_TYPES.BOUNCING:
		bullet = BB_SCENE.instantiate()
	else:
		bullet = BULLET_SCENE.instantiate()
	get_parent().add_child( bullet )
	bullet.init( level, self, bullet_type )
	bullet.fire( bullet_rotation, power )
	bullet.position =  fire_point.global_position


func fire_laser() -> void:
	$LaserSound.play()
	if anim.flip_h:
		laser.points[ 0 ] = Vector2( -laser_length / 4, 0 )
		laser.points[ 1 ] = Vector2( -5, 0 )
	else:
		laser.points[ 0 ] = Vector2( ( laser_length / 4 ) + 1, 0 )
	laser.modulate.a = 0
	laser.show()
	var tween = create_tween()
	tween.tween_property( laser, "modulate", Color.DARK_RED, 0.15 )
	tween.tween_property( laser, "modulate", Color( 1, 0, 0, 0.5 ), 0.15 )
	tween.tween_property( laser, "modulate", Color.ORANGE_RED, 0.1 )
	tween.tween_property( laser, "modulate", Color.ORANGE, 0.15 )
	tween.tween_property( laser, "modulate", Color.ORANGE_RED, 0.15 )
	tween.tween_property( laser, "modulate", Color( 1, 0, 0, 0.5 ), 0.15 )
	tween.tween_property( laser, "modulate", Color.DARK_RED, 0.15 )
	tween.tween_property( laser, "modulate", Color( 1, 0, 0, 0 ), 0.15 )
	var start = Vector2i(
		roundi( fire_point.global_position.x / level.scale ),
		roundi( fire_point.global_position.y / level.scale )
	)
	var end = Vector2i(
		roundi( laser_pos.x / level.scale ),
		roundi( laser_pos.y / level.scale )
	)
	level.on_laser_fired.emit( start, end )
	await $LaserSound.finished
	var hits: Array = raycast_2d_all( fire_point.global_position, laser_pos )
	for hit in hits:
		var parent = hit.collider.get_parent()
		var tank_hit
		var hit_position
		if parent.is_in_group( "RAF_Mine" ):
			hit_position = parent.position
		else:
			tank_hit = parent.get_parent()
			hit_position = tank_hit.position
		var explosion = EXPLOSION_SCENE.instantiate()
		explosion.scale = Vector2( 1, 1 )
		explosion.init( level, self )
		explosion.hits.append( tank_hit )
		var bullet_data = Raf.bullet_data[ Raf.BULLET_TYPES.LASER ]
		explosion.force = bullet_data.force
		explosion.radius = bullet_data.radius
		explosion.points = bullet_data.points
		explosion.position = hit_position
		get_parent().add_child( explosion )
	is_turn = false
	level.on_turn_ended.emit( 1.5 )


func raycast_2d_all( start: Vector2, end: Vector2 ) -> Array:
	var space_state = get_world_2d().direct_space_state
	var from = start
	var excludes = []
	var results = []
	var max_iterations = 100 # To avoid infinite loops
	
	for i in range( max_iterations ):
		var query = PhysicsRayQueryParameters2D.create( from, end )
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.exclude = excludes
		var result = space_state.intersect_ray( query )
		
		# Break if no more intersections are found
		if result.is_empty():
			break
		
		# Store the result
		results.append( result )
		
		# Update the starting point to continue from after the hit
		from = result.position
		
		# Optional: Adjust the start position slightly to avoid hitting the same point
		from += ( end - from ).normalized() * 0.01
		
		# Add the collider to the exclude list to avoid hitting it again
		excludes.append( result.collider.get_rid() )
	
	return results


func set_bullet_type() -> void:
	var selected_items: Array = bullet_select.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[ 0 ]
		var bullet_data = bullet_select.get_item_metadata( selected_index )
		bullet_type = bullet_data[ 0 ]
	else:
		printerr( "Cannot set bullet (%s)" % bullet_select.item_count )


func get_bullet_power( f: float ) -> float:
	return MIN_POWER + ( MAX_POWER - MIN_POWER ) * f


func get_bullet_rotation() -> float:
	var bullet_rotation: float
	if anim.flip_h:
		bullet_rotation = body.rotation + cannon.rotation + PI
	else:
		bullet_rotation = body.rotation + cannon.rotation
	
	return bullet_rotation


func show_spots() -> void:
	spots.show()
	spots.modulate.a = 0
	var tween = create_tween()
	tween.tween_property( spots, "modulate:a", 0.5, 0.5 )
	target_point.hide()


func hide_spots() -> void:
	var tween = create_tween()
	tween.tween_property( spots, "modulate:a", 0, 0.25 )
	await tween.finished
	spots.hide()
	#target_point.show()


func set_marker_points( delta: float ) -> void:
	var angle = get_bullet_rotation()
	var speed = get_bullet_power( fire_power )
	var bullet_data = Raf.bullet_data[ bullet_type ]
	if bullet_data.type == "laser":
		speed *= 2
	var vel = Vector2( cos( angle ) * speed, sin( angle ) * speed )
	var pos: Vector2 = fire_point.global_position
	var tick_count: int = 5
	for spot in spots.get_children():
		for i in tick_count:
			var ratio = ( level.height - ( pos.y / level.scale ) ) / level.height
			var wind = level.wind * ratio
			if bullet_data.type == "laser":
				pos += vel * delta
				laser_length = abs( position.x - pos.x )
				laser_pos = pos
			else:
				pos += ( vel + wind ) * delta
				vel += level.gravity
		spot.global_position = pos


func set_tank_colors() -> void:
	Globals.swap_colors( anim, colors, SWAP_COLORS )


func can_move( dx: float ) -> bool:
	var pos_x = position.x + dx
	if dx > 0:
		pos_x += tank_radius / 3 * level.scale
	if dx < 0:
		pos_x -= tank_radius / 3 * level.scale
	var x: int = clampi( roundi( pos_x / level.scale ), 0, level.width - 1 )
	var pos_height: int = level.heights[ x ]
	var last_height: int = roundi(
		( ( position.y - 2 ) / level.scale ) + float( tank_height ) / 2
	)
	var slope = last_height - pos_height
	var max_slope = anim.scale.y * 5
	if slope > max_slope:
		return false
	return true


func check_can_move( dx: float ) -> bool:
	var pos_x = position.x + dx
	if dx > 0:
		pos_x += tank_radius / 3 * level.scale
		if pos_x >= level.width * level.scale - BUFF_X:
			return false
	elif dx < 0:
		pos_x -= tank_radius / 3 * level.scale
		if pos_x <= BUFF_X:
			return false
	return can_move( dx )


func set_tank_on_hill() -> void:
	set_tank_vertical()
	set_tank_slope()


func set_tank_vertical() -> void:
	var x: int = clampi( roundi( position.x / level.scale ), 0, level.width - 1 )
	var y: int = level.heights[ x ]
	position.y = ( y - tank_height / 2 ) * level.scale


func set_tank_slope() -> void:
	var range_x = get_tank_x_range()
	var slope_points: Array = []
	for x in range( range_x[ 0 ], range_x[ 1 ] ):
		slope_points.append( level.heights[ x ] )
	
	var angle = 0
	if slope_points.size() >= 2:
		var dx = range_x[ 1 ] - range_x[ 0 ]
		var dy = slope_points[ slope_points.size() - 1 ] - slope_points[ 0 ]
		angle = atan2( dy, dx )
	
	target_rotation = angle


func get_tank_x_range( range_radius: int = 2 ) -> Array:
	var offset_x: float
	if anim.flip_h:
		offset_x = -tank_radius
	else:
		offset_x = tank_radius
	var start_x = clampi(
		roundi( ( position.x - offset_x ) / level.scale ) - range_radius, 0, level.width - 1
	)
	var end_x = clampi( start_x + range_radius * 2, 0, level.width - 1 )
	return [ start_x, end_x ]


func set_tank_grounded() -> void:
	var x: int = clampi( roundi( position.x / level.scale ), 0, level.width - 1 )
	var y: int = roundi( position.y / level.scale ) + roundi( tank_height / 2 )
	if level.heights[ x ] <= y:
		if velocity.y > 0:
			velocity.y = 0
		velocity = velocity - velocity.normalized() * 1.5
		if velocity.x > 200:
			velocity.x = minf( velocity.x, 150.0 )
		elif velocity.x < -200:
			velocity.x = maxf( velocity.x, -150.0 )
		if not is_boosting and velocity.length_squared() < 10.0:
			is_grounded = true
			velocity = Vector2.ZERO
			if is_booster_activated:
				end_booster()
		set_tank_on_hill()


func end_booster() -> void:
	is_booster_activated = false
	remove_current_bullet()
	is_turn = false
	level.on_turn_ended.emit( 0.5 )


func set_tank_position( pos: Vector2 ) -> void:
	var last_pos = position
	position = Vector2(
		clampf( pos.x, BUFF_X, level.width * level.scale - BUFF_X ),
		pos.y
	)
	if is_grounded:
		var distance_travelled: float = abs( position.distance_to( last_pos ) )
		movement_points_remaining -= distance_travelled / 15


func set_tank_flipped() -> void:
	if $Body/Anim.flip_h != is_facing_left:
		$Body/Anim/Cannon.position.x *= -1
		$Body/Anim/Cannon.offset.x *= -1
		$Body/Anim/Cannon/Marker2D.position.x *= -1
		$Body/Anim/Cannon/Target.position.x *= -1
		$Body/Anim.flip_h = is_facing_left
		if cannon != null:
			var dir = "RIGHT_"
			if is_facing_left:
				dir = "LEFT_"
			cannon.rotation = clampf(
				cannon.rotation, CANNON_ROT[ dir + "MIN" ], CANNON_ROT[ dir + "MAX" ]
			)
		set_collision_shape()
	if $Body/Anim.flip_h:
		$BulletImage.flip_h = false
		$BulletImage.position.x = -70
		$AngleLabel.position.x = 50
		$MovementLabel.position.x = 60
	else:
		$BulletImage.flip_h = true
		$BulletImage.position.x = 72
		$AngleLabel.position.x = -110
		$MovementLabel.position.x = -110


func set_collision_shape() -> void:
	if anim == null:
		anim = $Body/Anim
	var collision_left: CollisionPolygon2D
	var collision_right: CollisionPolygon2D
	if anim.scale.x == 2:
		collision_left = $Body/Area2D/CollisionLeft
		collision_right = $Body/Area2D/CollisionRight
		$Body/Area2D/CollisionLeft4.set_deferred( "disabled", true )
		$Body/Area2D/CollisionRight4.set_deferred( "disabled", true )
		$Body/Area2D/CollisionLeft6.set_deferred( "disabled", true )
		$Body/Area2D/CollisionRight6.set_deferred( "disabled", true )
	elif anim.scale.x == 4:
		collision_left = $Body/Area2D/CollisionLeft4
		collision_right = $Body/Area2D/CollisionRight4
		$Body/Area2D/CollisionLeft.set_deferred( "disabled", true )
		$Body/Area2D/CollisionRight.set_deferred( "disabled", true )
		$Body/Area2D/CollisionLeft6.set_deferred( "disabled", true )
		$Body/Area2D/CollisionRight6.set_deferred( "disabled", true )
	elif anim.scale.x == 6:
		collision_left = $Body/Area2D/CollisionLeft6
		collision_right = $Body/Area2D/CollisionRight6
		$Body/Area2D/CollisionLeft.set_deferred( "disabled", true )
		$Body/Area2D/CollisionRight.set_deferred( "disabled", true )
		$Body/Area2D/CollisionLeft4.set_deferred( "disabled", true )
		$Body/Area2D/CollisionRight4.set_deferred( "disabled", true )
	if is_facing_left:
		if collision_left != null:
			collision_left.set_deferred( "disabled", false )
		else:
			printerr( "Collision shape dissappeard" )
		if collision_right != null:
			collision_right.set_deferred( "disabled", true )
		else:
			printerr( "Collision shape dissappeard" )
		muzzle_fire = $Body/Anim/Cannon/Marker2D/MuzzleFireLeft
		#$Body/Area2D/CollisionLeft.show()
		#$Body/Area2D/CollisionRight.hide()
	else:
		collision_left.set_deferred( "disabled", true )
		collision_right.set_deferred( "disabled", false )
		muzzle_fire = $Body/Anim/Cannon/Marker2D/MuzzleFireRight
		#$Body/Area2D/CollisionLeft.hide()
		#$Body/Area2D/CollisionRight.show()
	if get_parent() != null:
		if not is_inside_tree():
			return
		await get_tree().physics_frame
	for c: CollisionPolygon2D in $Body/Area2D.get_children():
		if c.disabled:
			c.hide()
		else:
			c.show()


func calc_slime_penalty( max_count: int = 5, factor: int = 1 ) -> void:
	for gp in ground_points:
		var x = roundi( gp.global_position.x / level.scale )
		if x >= 0 and x < level.width:
			var y = level.heights[ x ]
			if y <= roundi( gp.global_position.y / level.scale ):
				gp.get_child( 0 ).modulate = Color.RED
				var color: Color = level.img.get_pixel( x, y )
				if Globals.are_colors_simular( color, Raf.SLIME_COLOR ):
					slime_count += factor
			else:
				gp.get_child( 0 ).modulate = Color.WHITE
	if not is_waiting_for_slime_count and slime_count > 0:
		is_waiting_for_slime_count = true
		await get_tree().create_timer( 0.25 ).timeout
		is_waiting_for_slime_count = false
		add_points( -clampi( slime_count, 0, max_count ), position, self )
		slime_count = 0


func get_input( action: String, just: bool = false, released: bool = false ) -> bool:
	if Raf.is_paused:
		return false
	if is_cpu:
		return cpu_ai.get_input( action, just, released )
	if Globals.is_cursor_mode:
		return false
	if just:
		return Input.is_action_just_pressed( action )
	elif released:
		return Input.is_action_just_released( action )
	else:
		return Input.is_action_pressed( action )
