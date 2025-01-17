extends RigidBody2D
class_name BlastShipBody


const HIT_CREDIT_DURATION = 3.0
const LOW_POWER_PCT = 0.333
const GUN_POINTS: Array = [
	[ Vector2( 28, -20 ), Vector2( 28, 22 ) ],
	[ Vector2( 28, -6 ), Vector2( 28, 6 ) ],
]
const ACTION_NAMES: Array = [
	"ToggleDown_",
	"ToggleUp_",
	"Left_",
	"Right_",
	"Up_",
	"Down_",
	"Fire_"
]


@export var world_id: int = 0
@export var controls: String = "ANY"
@export var display_name: String = "Player 1"


var crosshair_x: float = 200.0
var ship_color: Color = Color.BLUE
var ui_color: Color
var cpu_ai: BlastCpuAi
var is_cpu: bool = false
var rotation_speed = PI / 2
var max_rotation_speed = TAU
var min_roation_speed = PI / 2
var game: BlastGame
var thrust_force: float = 4000
#var thrust_force: float = 40000
var dampening_factor: float = 0.0005
#var dampening_factor: float = 0
var last_pos: Vector2
var camera_pos: Vector2
var clones: Array = []
var main_clone: BlastShip
var minimap_clones: Array = []
var nav_clones: Array = []
var was_thrusting: bool = false
var is_thrusting: bool = false
var start_thrusting: bool = false
var stop_thrusting: bool = false
var speed: float = 0
var cooldown_time: float = 0
var boost_charge_stop: float = 0
var lives: int = 3:
	set( value ):
		lives = value
		if lives_box:
			for i in range( lives_box.get_child_count() ):
				if i < lives:
					lives_box.get_child( i ).show()
				else:
					lives_box.get_child( i ).hide()
var max_laser_energy: float = 500
var laser_charge_rate: float = 75
var laser_energy: float = 500:
	set( value ):
		laser_energy = value
		if weapons_bar:
			weapons_bar.value = ( laser_energy / max_laser_energy ) * 100
			var low_power = max_laser_energy * LOW_POWER_PCT
			if laser_energy < low_power:
				weapons_bar.modulate.a = ( laser_energy / low_power ) * 0.25 + 0.75
var shields_radius: float = 30.0
var max_shields: float = 1000
var min_shields: float = 100
var is_shields_down: bool = false
var shields: float = 1000:
	set( value ):
		shields = value
		if shields_bar:
			shields_bar.value = ( shields / max_shields ) * 100
var max_health: float = 1000
var health: float = 1000:
	set( value ):
		health = value
		if health_bar:
			health_bar.value = ( health / max_health ) * 100
var max_energy: float = 10000
var energy: float = 10000:
	set( value ):
		energy = value
		if energy_bar:
			energy_bar.value = ( energy / max_energy ) * 100
var min_energy: float = max_energy / 100
var shield_charge_rate: float = 50
var thrust_drain: float = 150
var life_support_energy: float = 10
var is_destroyed: bool = false
var nearby_objs: Array = []
var nearby_enemies: Array = []
var health_bar: ProgressBar
var shields_bar: ProgressBar
var energy_bar: ProgressBar
var weapons_bar: ProgressBar
var lives_box: HBoxContainer
var weapon_box: HBoxContainer
var ammo_label: Label
var coordinates_label: Label
var is_alternate_tick: bool = false
#var weapon_data2: Dictionary
var weapon: String:
	set( value ):
		weapon = value
		#weapon_data2 = BlastGame.WEAPONS_DATA[ weapon ]
var weapon_store: Array = []
var weapon_index: int
var ammo: Dictionary = {}
var blast_charge_size: float = 0
var is_invulnerable: bool = false
var is_game_over: bool = false
var stats: Dictionary = {
	"ship_kills": 0,
	"asteroid_kills": 0,
	"crate_kills": 0,
	"missile_kills": 0
}
var lives_image
var body_collision: CollisionPolygon2D
var base_gun_points: Array
var energy_tween: Tween
var is_burning: bool = false
var is_laser_firing: bool = false
var is_shields_hit: bool = false
var is_body_hit: bool = false
var collide_sound_volume: float = 0
var is_selecting: bool = false
var is_charging: bool = false
var last_hit_by: BlastShipBody
var last_hit_time: float = 0
var enabled_actions: Dictionary = {}


@onready var nav_marker: Sprite2D = $NavMarker
@onready var gun_points: Node2D = $GunPoints
@onready var missile_point: Node2D = $MissilePoint
@onready var shapecast: ShapeCast2D = $ShapeCast2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var sprite_markers: Sprite2D = $Sprite2D/Sprite2D
@onready var shields_collision: CollisionShape2D = $ShieldsCollision


func init( new_game: BlastGame ) -> void:
	nav_marker.reparent( get_parent() )
	game = new_game
	if world_id > -1:
		init_ui()
	lives = Blast.data.settings.lives_count + 1
	add_weapon( "laser" )
	weapon_index = 0
	select_weapon()
	init_clones()
	reset_ship()


func init_ui() -> void:
	var ui = game.uis[ world_id ]
	game.ui_items.append( ui )
	health_bar = ui.get_node( "ShipData/HealthBar" )
	shields_bar = ui.get_node( "ShipData/ShieldsBar" )
	energy_bar = ui.get_node( "ShipData/EnergyBar" )
	weapons_bar = ui.get_node( "WeaponsData/WeaponsBar" )
	ammo_label = ui.get_node( "WeaponsData/WeaponsBar/AmmoCount" )
	weapon_box = ui.get_node( "WeaponsData/Control/HB" )
	coordinates_label = ui.get_node( "Control/CoordinatesLabel" )
	lives_box = game.uis[ world_id ].get_node( "Lives/HB" )
	for child in lives_box.get_children():
		var child_sprite: Sprite2D = child.get_child( 0 )
		child_sprite.texture = lives_image
		child_sprite.modulate = ui_color
		child_sprite.modulate.a = 0.8


func setup_ship( settings: Dictionary ) -> void:
	var settings_colors: int = 0
	var settings_image_id: int = 0
	if settings.colors == null:
		settings_colors = randi_range( 0, Globals.BLAST_COLORS.size() - 1 )
	else:
		settings_colors = settings.colors
	if settings.image_id == null:
		settings_image_id = randi_range( 0, Globals.BLAST_IMAGES.size() - 1 )
	else:
		settings_image_id = settings.image_id
	ship_color = Globals.BLAST_COLORS[ settings_colors ][ 0 ]
	ui_color = Globals.BLAST_COLORS[ settings_colors ][ 1 ]
	if settings.name_changed:
		display_name = settings.name
	else:
		display_name = tr( settings.name )
	controls = settings.controls
	sprite.texture = Globals.BLAST_IMAGES[ settings_image_id ][ 0 ]
	sprite_markers.texture = Globals.BLAST_IMAGES[ settings_image_id ][ 1 ]
	sprite_markers.modulate = ship_color
	lives_image = Globals.BLAST_IMAGES[ settings_image_id ][ 2 ]
	if settings_image_id == 0:
		body_collision = $BodyCollision1
		base_gun_points = GUN_POINTS[ 0 ]
	else:
		body_collision = $BodyCollision2
		base_gun_points = GUN_POINTS[ 1 ]
	gun_points.get_child( 0 ).position = base_gun_points[ 0 ]
	gun_points.get_child( 1 ).position = base_gun_points[ 1 ]
	is_cpu = controls == "CPU"
	if is_cpu:
		cpu_ai = BlastCpuAi.new()
		cpu_ai.init( self )
	enable_controls( ACTION_NAMES )


func setup_weapon() -> void:
	var ui = game.uis[ world_id ]
	var weapon_marker: TextureRect = ui.get_node( "WeaponsData/WeaponImage/WeaponMarker" )
	var weapon_image: TextureRect = ui.get_node( "WeaponsData/WeaponImage" )
	var weapon_data = BlastGame.WEAPONS_DATA[ weapon ]
	weapon_image.texture = weapon_data.UI_IMAGE
	weapon_marker.texture = weapon_data.UI_MARKER
	weapon_marker.modulate = ship_color
	var weapon_stylebox: StyleBoxFlat = StyleBoxFlat.new()
	weapon_stylebox.bg_color = ui_color
	weapon_stylebox.bg_color.a = 0.75
	weapons_bar.add_theme_stylebox_override( "fill", weapon_stylebox )


func select_weapon() -> void:
	blast_charge_size = 0
	is_charging = false
	weapon = weapon_store[ weapon_index ]
	if world_id == -1:
		return
	var ui = game.uis[ world_id ]
	var weapon_store_ui: HBoxContainer = ui.get_node( "WeaponsData/Control/HB" )
	for i in range( weapon_store_ui.get_child_count() ):
		var panel: Panel = weapon_store_ui.get_child( i )
		var store_stylebox: StyleBoxFlat = StyleBoxFlat.new()
		store_stylebox.bg_color = Color( 0, 0, 0, 0.63 )
		store_stylebox.set_border_width_all( 4 )
		store_stylebox.border_blend = true
		if i == weapon_index:
			store_stylebox.border_color = Color.WHITE
		else:
			store_stylebox.border_color = Color( 1, 1, 1, 0.25 )
		panel.add_theme_stylebox_override( "panel", store_stylebox )
	setup_weapon()
	update_ammo()


func update_ammo() -> void:
	if world_id == -1:
		return
	var weapon_data = BlastGame.WEAPONS_DATA[ weapon ]
	if weapon_data.AMMO_TYPE == "physical":
		ammo_label.show()
		ammo_label.text = "%d" % ammo[ weapon ]
	elif weapon_data.AMMO_TYPE == "energy":
		ammo_label.hide()


func add_weapon( new_weapon: String ) -> void:
	var new_weapon_data = BlastGame.WEAPONS_DATA[ new_weapon ]
	
	# Add physical ammo
	if new_weapon_data.AMMO_TYPE == "physical":
		if not ammo.has( new_weapon ):
			ammo[ new_weapon ] = 0
		ammo[ new_weapon ]  += 1
		if new_weapon == weapon:
			update_ammo()
	elif new_weapon_data.AMMO_TYPE == "energy":
		pickup( 500.0, true )
	
	if weapon_store.find( new_weapon ) == -1:
		weapon_store.append( new_weapon )
		show_hide_weapons()


func show_hide_weapons() -> void:
	if world_id == -1:
		return
	for panel in weapon_box.get_children():
		panel.get_child( 0 ).hide()
		panel.get_child( 1 ).hide()
	for i in range( weapon_store.size() ):
		var sel_weapon: String = weapon_store[ i ]
		var panel: Panel = weapon_box.get_child( i )
		var weapon_sprite: Sprite2D = panel.get_child( 0 )
		var weapon_sprite2: Sprite2D = panel.get_child( 1 )
		var data = BlastGame.WEAPONS_DATA[ sel_weapon ]
		weapon_sprite.show()
		weapon_sprite.modulate.a = 1
		weapon_sprite.texture = data.UI_IMAGE
		weapon_sprite2.show()
		weapon_sprite2.texture = data.UI_MARKER
		weapon_sprite2.modulate = ship_color


func init_clones() -> void:
	for i in range( game.worlds.size() ):
		var world = game.worlds[ i ]
		
		# Create Clone Ship
		var clone_ship: BlastShip = game.scenes.SHIP.instantiate()
		clone_ship.ship_body = self
		if i == world_id:
			clone_ship.is_main_ship = true
			main_clone = clone_ship
		world.add_child( clone_ship )
		clone_ship.sprite.texture = sprite.texture
		clone_ship.sprite_markers.texture = sprite_markers.texture
		clones.append( clone_ship )
		
		# Create Clone Nav Marker
		var clone_nav: Sprite2D = Sprite2D.new()
		if not Globals.is_debug:
			clone_nav.modulate.a = 0
		clone_nav.texture = nav_marker.texture
		clone_ship.add_child( clone_nav )
		nav_clones.append( clone_nav )
		
		# Create minimap clone
		var minimap = game.minimaps[ i ]
		var minimap_clone: Sprite2D = Sprite2D.new()
		minimap_clone.rotation = deg_to_rad( -90 )
		minimap_clone.scale = Vector2( 3, 3 )
		minimap_clone.texture = clone_ship.sprite.texture
		minimap_clone.material = game.create_minimap_material( ui_color )
		minimap_clones.append( minimap_clone )
		minimap.add_child( minimap_clone )
		if i == world_id:
			var camera: Camera2D = Camera2D.new()
			var rect: Rect2 = Blast.get_rect()
			camera.limit_left = roundi( rect.position.x ) - 100
			camera.limit_right = roundi( rect.position.x + rect.size.x ) + 100
			camera.limit_top = roundi( rect.position.y ) - 100
			camera.limit_bottom = roundi( rect.position.y + rect.size.y ) + 100
			minimap_clone.add_child( camera )


func update_clones( delta: float ) -> void:
	for clone in clones:
		clone.update( delta )
	for nav_clone in nav_clones:
		nav_clone.global_position = nav_marker.global_position
	for clone in minimap_clones:
		clone.position = position
		clone.rotation = rotation


func apply_thrust( delta: float, mult: float = 1.0 ) -> void:
	
	if energy <= thrust_drain * delta:
		return
	
	# Calculate the thrust vector in the ship's forward direction
	var thrust_vector = Vector2.RIGHT.rotated( rotation ) * ( thrust_force * mult )
	
	# Only apply dampening if the ship is accelerating forward
	var current_velocity = Vector2( linear_velocity )
	var velocity_dot_thrust = current_velocity.dot( thrust_vector )
	
	# Apply the dampening only when accelerating forward
	if velocity_dot_thrust >= 0:
		var dampening_force = -thrust_vector.normalized() * dampening_factor * velocity_dot_thrust
		apply_force( dampening_force )

	# Apply the actual thrust force
	apply_force( thrust_vector )
	
	is_thrusting = true


func can_cpu_fire() -> bool:
	return laser_energy >= max_laser_energy * 0.25


func fire_lasers( delta: float ) -> void:
	var is_low_power_mode = false
	var weapon_data = BlastGame.WEAPONS_DATA[ weapon ]
	if weapon_data.AMMO_TYPE == "energy":
		var drain = weapon_data.DRAIN
		if laser_energy < max_laser_energy * 0.25:
			drain = drain * 0.333
			is_low_power_mode = true
		if laser_energy < drain * delta:
			if main_clone != null and not main_clone.invalid_sound.playing:
				main_clone.invalid_sound.play()
			return
		laser_energy -= weapon_data.DRAIN * delta
	elif weapon_data.AMMO_TYPE == "physical":
		if ammo[ weapon ] < 1:
			for clone: BlastShip in clones:
				if not clone.invalid_sound.playing:
					clone.invalid_sound.play()
			return
		ammo[ weapon ] -= 1
		update_ammo()
	is_laser_firing = true
	var laser_velocity = linear_velocity + Vector2.from_angle( rotation ) * weapon_data.SPEED
	if weapon_data.TYPE == "missile" or weapon_data.TYPE == "bomb":
		var missile: BlastMissileBody = game.scenes.MISSILE_BODY.instantiate()
		missile.position = missile_point.global_position
		get_parent().add_child( missile )
		missile.init( self, weapon_store[ weapon_index ] )
		missile.fire( laser_velocity, ship_color, rotation )
	elif weapon_data.TYPE == "energy":
		for gun_point in gun_points.get_children():
			gun_point.position.x = base_gun_points[ 0 ].x + 7
			var bullet: BlastLaser = game.scenes.LASER.instantiate()
			bullet.mass = weapon_data.MASS
			bullet.position = gun_point.global_position
			bullet.spin = weapon_data.SPIN
			get_parent().add_child( bullet )
			bullet.sprite.scale = weapon_data.SCALE
			bullet.sprite.texture = weapon_data.IMAGE
			bullet.init( self, weapon_store[ weapon_index ] )
			if is_low_power_mode:
				var laser_color = ui_color
				laser_color.a = 0.75
				bullet.fire( laser_velocity, laser_color, weapon_data.DAMAGE, rotation )
			else:
				bullet.fire( laser_velocity, ui_color, weapon_data.DAMAGE, rotation )
	elif weapon_data.TYPE == "spread":
		for gun_point in gun_points.get_children():
			gun_point.position.x = base_gun_points[ 0 ].x + 7
			for a in [ -PI / 8, 0, PI / 8 ]:
				var bullet: BlastLaser = game.scenes.LASER.instantiate()
				bullet.mass = weapon_data.MASS
				bullet.position = gun_point.global_position
				bullet.spin = weapon_data.SPIN
				get_parent().add_child( bullet )
				bullet.sprite.scale = weapon_data.SCALE
				bullet.sprite.texture = weapon_data.IMAGE
				bullet.init( self, weapon_store[ weapon_index ] )
				var vel =  linear_velocity + Vector2.from_angle( rotation + a ) * weapon_data.SPEED
				if is_low_power_mode:
					var laser_color = ui_color
					laser_color.a = 0.75
					bullet.fire( vel, laser_color, weapon_data.DAMAGE, rotation )
				else:
					bullet.fire( vel, ui_color, weapon_data.DAMAGE, rotation )
	elif weapon_data.TYPE == "charge":
		for gun_point in gun_points.get_children():
			gun_point.position.x = base_gun_points[ 0 ].x + blast_charge_size * 10
			var bullet: BlastLaser = game.scenes.LASER.instantiate()
			bullet.mass = weapon_data.MASS
			bullet.position = gun_point.global_position
			bullet.spin = weapon_data.SPIN
			get_parent().add_child( bullet )
			bullet.sprite.scale = weapon_data.SCALE * blast_charge_size
			bullet.sprite.texture = weapon_data.IMAGE
			bullet.init( self, weapon_store[ weapon_index ] )
			bullet.fire(
				laser_velocity, ui_color, weapon_data.DAMAGE * blast_charge_size * 2, rotation
			)
	if weapon_data.AMMO_TYPE == "physical" and ammo[ weapon ] == 0:
		weapon_store.erase( weapon )
		show_hide_weapons()
		toggle_weapon_down()


func destroy( is_burned: bool = false ) -> void:
	if is_destroyed:
		return
	if last_hit_by != null and last_hit_time > Time.get_ticks_msec() - HIT_CREDIT_DURATION:
		last_hit_by.stats.ship_kills += 1
	speed = 0
	is_destroyed = true
	for clone in clones:
		if not is_burned and not clone.explosion_sound.playing:
			clone.explosion_sound.play()
		var clone_sprite: Sprite2D = clone.get_node( "Sprite2D" )
		var tween = create_tween()
		tween.tween_property( clone_sprite, "modulate:a", 0, 0.5 )
		clone.hide_health_bar()
	for clone in minimap_clones:
		clone.modulate.a = 0
	modulate.a = 0.5
	if not is_burned:
		await game.create_explosions( 10, shields_radius, self, 1.5 )
		var count: int = roundi( ( energy / max_energy ) * 30 )
		game.create_pickups( position, linear_velocity, count, 100, 5 )
	disable()
	lives -= 1
	await get_tree().create_timer( 1.5 ).timeout
	if lives >= 0:
		reset_ship()
	else:
		is_game_over = true
		if not Blast.data.is_tutorial:
			game.set_game_over()


func disable() -> void:
	set_collisions( false )
	is_thrusting = false
	stop_thrusting = true
	collide_sound_volume = 0


func reset_ship() -> void:
	if is_cpu:
		cpu_ai.set_state( cpu_ai.STATE.IDLE )
	is_invulnerable = true
	var is_clear: bool = false
	health = max_health
	shields = max_shields
	laser_energy = max_laser_energy
	energy = max_energy
	while not is_clear:
		position = game.get_random_start_pos( 500 )
		shapecast.target_position = Vector2.ZERO
		shapecast.force_shapecast_update()
		is_clear = not shapecast.is_colliding()
	if Blast.data.settings.map_type > 0:
		linear_velocity = game.get_orbit_velocity( self )
	modulate.a = 1.0
	var duration: float = 1.5
	for clone in clones:
		if clone.is_main_ship:
			clone.start_sound.play()
		var clone_sprite: Sprite2D = clone.get_node( "Sprite2D" )
		var tween = create_tween()
		var blinks: Array = [ 1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5, 1 ]
		for blink in blinks:
			tween.tween_property( clone_sprite, "modulate:a", blink, duration / blinks.size() )
	for clone in minimap_clones:
		clone.modulate.a = 1
	is_destroyed = false
	set_collisions( true )
	await get_tree().create_timer( duration ).timeout
	is_invulnerable = false


func get_input( action: String, just: bool = false, released: bool = false ) -> bool:
	if not enabled_actions[ action ]:
		return false
	if is_cpu:
		return cpu_ai.get_input( action, just, released )
	if just:
		return Input.is_action_just_pressed( action )
	elif released:
		return Input.is_action_just_released( action )
	else:
		return Input.is_action_pressed( action )


func get_target_rotation( target_angle: float, delta: float ) -> float:
	var current_angle = Globals.normalize_angle( rotation )
	target_angle = Globals.normalize_angle( target_angle )
	var vec1 = Vector2.from_angle( current_angle )
	var vec2 = Vector2.from_angle( target_angle )
	var between = vec1.angle_to( vec2 )
	if abs( between ) <= rotation_speed * delta:
		return 0
	if between > 0:
		if between > PI:
			return -rotation_speed
		else:
			return rotation_speed
	else:
		if between > PI:
			return rotation_speed
		else:
			return -rotation_speed


func process_weapon() -> void:
	if get_input( "ToggleDown_" + controls, true ):
		toggle_weapon_up()
	if get_input( "ToggleUp_" + controls, true ):
		toggle_weapon_down()


func toggle_weapon_up() -> void:
	weapon_index += 1
	if weapon_index >= weapon_store.size():
		weapon_index = 0
	select_weapon()
	if weapon_store.size() > 1:
		is_selecting = true
	else:
		for clone: BlastShip in clones:
			if not clone.invalid_sound.playing:
				clone.invalid_sound.play()


func toggle_weapon_down() -> void:
	weapon_index -= 1
	if weapon_index < 0:
		weapon_index = weapon_store.size() - 1
	select_weapon()
	if weapon_store.size() > 1:
		is_selecting = true
	else:
		for clone: BlastShip in clones:
			if not clone.invalid_sound.playing:
				clone.invalid_sound.play()


func process_rotation() -> void:
	if get_input( "Left_" + controls ):
		angular_velocity = -rotation_speed
		rotation_speed = minf( rotation_speed + PI / 16, max_rotation_speed )
	elif get_input( "Right_" + controls ):
		angular_velocity = rotation_speed
		rotation_speed = minf( rotation_speed + PI / 16, max_rotation_speed )
	else:
		rotation_speed = min_roation_speed


func process_firing( delta: float ) -> void:
	var weapon_data = BlastGame.WEAPONS_DATA[ weapon ]
	if weapon_data.TYPE == "charge":
		if get_input( "Fire_" + controls, true ):
			blast_charge_size = 0.2
			is_charging = false
		elif get_input( "Fire_" + controls ):
			var charge_drain = weapon_data.CHARGE_DRAIN * delta
			if blast_charge_size < 5 and charge_drain < laser_energy:
				blast_charge_size += 1.5 * delta
				laser_energy -= charge_drain
				is_charging = true
			else:
				is_charging = false
		elif get_input( "Fire_" + controls, false, true ):
			fire_lasers( delta )
			blast_charge_size = 0
			is_charging = false
	elif Time.get_ticks_msec() > cooldown_time and get_input( "Fire_" + controls ):
		if energy > 0:
			cooldown_time = Time.get_ticks_msec() + weapon_data.COOLDOWN
			fire_lasers( delta )


func process_thrust( delta: float ) -> void:
	# Reset thrusting status
	is_thrusting = false
	
	# Apply a revese thrust
	if get_input( "Down_" + controls ):
		if speed > 10:
			var ta = linear_velocity.angle() + PI
			rotation_speed = max_rotation_speed
			var rotation_change = get_target_rotation( ta, delta )
			if rotation_change != 0:
				angular_velocity = rotation_change
			else:
				rotation = ta
				if speed > 20:
					apply_thrust( delta )
				elif speed > 15:
					apply_thrust( delta, 0.5 )
				else:
					apply_thrust( delta, 0.25 )
		else:
			linear_velocity = Vector2.ZERO
	
	# Thrusting Controls
	if get_input( "Up_" + controls ):
		apply_thrust( delta )
	speed = linear_velocity.length_squared()
	last_pos = position
	start_thrusting = false
	stop_thrusting = false
	if is_thrusting and not was_thrusting:
		start_thrusting = true
	if not is_thrusting and was_thrusting:
		stop_thrusting = true
	was_thrusting = is_thrusting


func process_energy( delta: float ) -> void:
	
	# Drain Engines Energy
	if is_thrusting:
		energy -= thrust_drain * delta
	
	recharge_lasers( delta )
	recharge_shields( delta )
	
	# Drain Life Support
	energy -= life_support_energy * delta
	
	# Get energy back from shields and lasers
	if energy < min_energy:
		
		# Charge from shields
		var shield_charge = ( shield_charge_rate * delta ) / 2
		if shield_charge > shields:
			shield_charge = shields
		shields -= shield_charge
		energy += shield_charge
		
		# Charge from lasers - Make sure can fire next laser
		var weapon_data = BlastGame.WEAPONS_DATA[ weapon ]
		if laser_energy > weapon_data.DRAIN * delta * 2:
			var laser_charge = ( laser_charge_rate * delta ) / 2
			if laser_charge > laser_energy:
				laser_charge = laser_energy
			laser_energy -= laser_charge
			energy += laser_charge
	
	if energy < 0:
		destroy()


func recharge_shields( delta: float ) -> void:
	if shields < max_shields and energy > min_energy:
		var recharge_rate = shield_charge_rate
		if boost_charge_stop > Time.get_ticks_msec():
			recharge_rate *= 3
		var charge = min( max_shields - shields, recharge_rate * delta )
		if charge > energy:
			charge = energy
		if shields + charge > max_shields:
			charge = max_shields - shields
		shields += charge
		energy -= charge
	if not is_shields_down and shields < min_shields:
		shields_collision.set_deferred( "disabled", true )
		body_collision.set_deferred( "disabled", false )
	if is_shields_down and shields >= min_shields:
		shields_collision.set_deferred( "disabled", false )
		body_collision.set_deferred( "disabled", true )


func recharge_lasers( delta: float ) -> void:
	if laser_energy < max_laser_energy and energy > min_energy:
		var recharge_rate = laser_charge_rate
		if boost_charge_stop > Time.get_ticks_msec():
			recharge_rate *= 3
		var charge = min( max_laser_energy - laser_energy, recharge_rate * delta )
		if charge > energy:
			charge = energy
		if laser_energy + charge > max_laser_energy:
			charge = max_laser_energy - laser_energy
		laser_energy += charge
		energy -= charge


func hit( damage: float, fired_from: BlastShipBody ) -> void:
	if is_destroyed or is_invulnerable:
		return
	if damage > 0 and fired_from != null:
		last_hit_by = fired_from
		last_hit_time = Time.get_ticks_msec()
	shields -= damage
	if shields > 0:
		is_shields_hit = true
		for clone in clones:
			clone.raise_shields()
	else:
		is_body_hit = true
	if shields < 0:
		health += shields
		shields = 0
		if health <= 0:
			destroy()
		else:
			for clone: BlastShip in clones:
				clone.show_health_bar()


func burn( damage: float ) -> void:
	if is_destroyed or is_invulnerable:
		return
	is_burning = true
	shields -= damage
	if shields < 0:
		health += shields
		shields = 0
		if health <= 0:
			is_burning = false
			destroy( true )


func pickup( boost: float, is_silent: bool = false ) -> void:
	if not is_silent:
		for clone: BlastShip in clones:
			var sound = clone.pickup_sounds.pick_random()
			if not sound.playing:
				sound.play()
	var energy_charge = boost
	if energy + boost > max_energy:
		energy_charge = max_energy - energy
	energy += energy_charge
	boost -= energy_charge
	
	if is_alternate_tick:
		# Charge Lasers
		if boost > 0:
			var laser_charge = boost
			if laser_energy + boost > max_laser_energy:
				laser_charge = max_laser_energy - laser_energy
			laser_energy += laser_charge
			boost -= energy_charge
			
		# Charge Shields
		if boost > 0:
			var shields_charge = boost
			if shields + boost > max_shields:
				shields_charge = max_shields - shields
			shields += shields_charge
	elif boost > 0:
		# Charge Shields
		if boost > 0:
			var shields_charge = boost
			if shields + boost > max_shields:
				shields_charge = max_shields - shields
			shields += shields_charge
			boost -= energy_charge
		
		# Charge lasers
		if boost > 0:
			var laser_charge = boost
			if laser_energy + boost > max_laser_energy:
				laser_charge = max_laser_energy - laser_energy
			laser_energy += laser_charge
	
	# Add charge boost
	boost_charge_stop = Time.get_ticks_msec() + 1000


func pickup_weapon( new_weapon: String ) -> void:
	for clone: BlastShip in clones:
		clone.pickup_sound.play()
	add_weapon( new_weapon )


func get_clones() -> Array:
	return clones


func process_observer_mode( delta: float ) -> void:
	linear_velocity = Vector2.ZERO
	update_clones( delta )


func process_crosshairs() -> void:
	if Blast.data.settings.show_crosshairs == 0:
		return
	shapecast.target_position = Vector2.RIGHT * 1000
	shapecast.force_shapecast_update()
	if shapecast.is_colliding() and shapecast.get_collider( 0 ).has_method( "hit" ):
		var cx = ( shapecast.get_collision_point( 0 ) - position ).length()
		if cx > crosshair_x:
			cx = crosshair_x
		main_clone.show_crosshair()
		main_clone.crosshair.position.x = cx
	else:
		main_clone.hide_crosshair()
		main_clone.crosshair.position.x = crosshair_x


func shapecast_2d( end: Vector2 ) -> Variant:
	var shape_cast: ShapeCast2D = shapecast
	shape_cast.rotation = -rotation
	shape_cast.target_position = end - position
	shape_cast.force_shapecast_update()
	Globals.debug_line( position, end, Color.YELLOW, 2, get_parent(), 1 )
	if shape_cast.is_colliding():
		return shape_cast.get_collider( 0 )
	return null


func set_collisions( is_enabled: bool ) -> void:
	set_collision_layer_value( 1, is_enabled )
	set_collision_mask_value( 1, is_enabled )


func reset_all_sounds() -> void:
	is_laser_firing = false
	is_burning = false
	is_shields_hit = false
	is_body_hit = false
	collide_sound_volume = 0
	is_selecting = false
	blast_charge_size = 0
	is_charging = false


func disable_controls() -> void:
	for action in ACTION_NAMES:
		enabled_actions[ action + controls ] = false


func enable_controls( actions: Array ) -> void:
	for action in actions:
		enabled_actions[ action + controls ] = true


func _ready() -> void:
	last_pos = position
	if Blast.data.player_count == 4:
		crosshair_x = 165


func _physics_process( delta: float ) -> void:
	if is_destroyed:
		reset_all_sounds()
		process_observer_mode( delta )
		return
	
	# Reset values
	angular_velocity = 0
	is_laser_firing = false
	is_selecting = false
	
	if is_cpu:
		cpu_ai.process( delta )
	else:
		process_crosshairs()
	
	process_weapon()
	process_rotation()
	process_firing( delta )
	process_thrust( delta )
	process_energy( delta )
	update_clones( delta )
	is_alternate_tick = !is_alternate_tick
	
	# Post process resets
	is_burning = false
	is_shields_hit = false
	is_body_hit = false
	collide_sound_volume = 0
	
	if world_id == -1:
		return
	coordinates_label.text = "(%d, %d)" % [
		roundi( position.x / 100 ),
		roundi( position.y / 100 )
	]


func _on_body_entered( node: Node2D ) -> void:
	if not node is RigidBody2D:
		return
	var body = node as RigidBody2D
	var relative_velocity = linear_velocity - body.linear_velocity
	var impact = relative_velocity.length()
	var damage = impact * log( body.mass )
	if damage > 0:
		var hit_by: BlastShipBody = null
		if node is BlastShipBody:
			hit_by = node as BlastShipBody
		if damage > 500:
			collide_sound_volume = 1.5
		elif damage > 1000:
			collide_sound_volume = 3
		elif damage > 1500:
			collide_sound_volume = 6
		hit( damage, hit_by )


func _on_area_2d_body_entered( body: Node2D ) -> void:
	if body != self and body.has_method( "hit" ):
		if body.has_method( "fire_lasers" ):
			nearby_enemies.append( body )
		else:
			nearby_objs.append( body )


func _on_area_2d_body_exited( body: Node2D ) -> void:
	if body != self and body.has_method( "hit" ):
		if body.has_method( "fire_lasers" ):
			nearby_enemies.erase( body )
		else:
			nearby_objs.erase( body )
