extends RigidBody2D


const EXPLOSION_SCENE = preload( "res://Games/ReadyAimFire/Scenes/explosion.tscn" )


var level: RAF_Level
var fired_from: RAF_Tank
var bullet_data: Dictionary
var is_alive: bool = false
var elapsed: float = 0
var explosion: RAF_Explosion


@onready var sprite: Sprite2D = $Sprite2D


func _physics_process( delta: float ) -> void:
	elapsed += delta
	if get_contact_count() > 0:
		elapsed += 0.15
		var bounce: float = linear_velocity.length_squared()
		var bounce_sound: AudioStreamPlayer = $BounceSound
		if bounce > 6400 and not bounce_sound.playing:
			bounce_sound.play()
	if elapsed > 6:
		explode( null )
		return
	if not get_is_in_bounds():
		destroy_bullet()
		return
	var ratio = ( level.height - ( position.y / level.scale ) ) / level.height
	var wind = level.wind * ratio
	#apply_impulse( wind * delta * 0.5 )
	apply_force( wind )
	if sleeping:
		explode( null )


func init( new_level: RAF_Level, source_tank: RAF_Tank, bullet_type: Raf.BULLET_TYPES ) -> void:
	level = new_level
	level.on_bullet_spawned.emit( self )
	fired_from = source_tank
	bullet_data = Raf.bullet_data[ bullet_type ]
	modulate = bullet_data.modulate
	sprite.scale = Vector2( bullet_data.bullet_scale, bullet_data.bullet_scale )
	sprite.texture = bullet_data.image
	is_alive = true


func fire( angle: float, power: float ) -> void:
	linear_velocity = Vector2.from_angle( angle ) * power * 1.33
	elapsed = 0


func get_is_in_bounds() -> bool:
	var x: int = roundi( position.x / level.scale )
	if x < 0 or x > level.width - 1:
		return false
	var y: int = roundi( position.y / level.scale )
	if y > level.height:
		return false
	return true


func explode( tank_hit: RAF_Tank ) -> void:
	if not is_alive:
		if bullet_data.has( "explosion_scale" ):
			explosion.hits.append( tank_hit )
		return
	is_alive = false
	if bullet_data.has( "explosion_scale" ):
		explosion = EXPLOSION_SCENE.instantiate()
		explosion.scale = Vector2( bullet_data.explosion_scale, bullet_data.explosion_scale )
		explosion.init( level, fired_from )
		explosion.hits.append( tank_hit )
		explosion.force = bullet_data.force
		explosion.radius = bullet_data.radius
		explosion.points = bullet_data.points
		explosion.position = position
		explosion.position.y += 4
		get_parent().add_child( explosion )
	destroy_bullet()


func destroy_bullet( delay: float = 1.5 ) -> void:
	level.on_turn_ended.emit( delay )
	level.on_bullet_spawned.emit( self )
	queue_free()


func detect_in_bounds() -> void:
	pass


func _on_area_2d_area_entered( area: Area2D ) -> void:
	var grand_parent = area.get_parent().get_parent()
	if grand_parent.is_in_group( "RAF_Tank" ):
		explode( grand_parent )
