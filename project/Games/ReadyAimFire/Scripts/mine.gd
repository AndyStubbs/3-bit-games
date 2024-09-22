extends Node2D


const EXPLOSION_SCENE = preload( "res://Games/ReadyAimFire/Scenes/explosion.tscn" )


var is_alive: bool = false
var bullet_data: Dictionary
var explosion: RAF_Explosion
var level: RAF_Level
var is_grounded = true
var velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	await get_tree().create_timer( 0.5 ).timeout
	$ActivateSound.play()
	await $ActivateSound.finished
	$Area2D.set_deferred( "monitorable", true )
	$Area2D.set_deferred( "monitoring", true )
	is_alive = true


func _physics_process( delta: float ) -> void:
	if not is_grounded:
		position += velocity * delta
		velocity += level.gravity
		var x = roundi( position.x / level.scale )
		if x < 0 or x > level.width - 1:
			queue_free()
			return
		var y = roundi( position.y / level.scale )
		if y > level.heights[ x ]:
			position.y = level.heights[ x ] * level.scale
			is_grounded = true


func init( new_level: RAF_Level, new_bullet_data: Dictionary ) -> void:
	level = new_level
	bullet_data = new_bullet_data
	level.on_heights_updated.connect( on_heights_updated )
	level.on_explosion.connect( on_explosion )


func explode( tank_hit: RAF_Tank ) -> void:
	if not is_alive:
		if bullet_data.has( "explosion_scale" ):
			explosion.hits.append( tank_hit )
		return
	is_alive = false
	if bullet_data.has( "explosion_scale" ):
		explosion = EXPLOSION_SCENE.instantiate()
		explosion.scale = Vector2( bullet_data.explosion_scale, bullet_data.explosion_scale )
		explosion.init( level, null )
		explosion.hits.append( tank_hit )
		explosion.force = bullet_data.force
		explosion.radius = bullet_data.radius
		explosion.points = bullet_data.points
		explosion.position = position
		explosion.position.y += 4
		get_parent().add_child( explosion )
	
	queue_free()


func on_heights_updated() -> void:
	is_grounded = false


func on_explosion( expl: RAF_Explosion ) -> void:
	var point: Vector2 = expl.position
	var radius: float = expl.radius * level.scale * 2
	if position.distance_to( point ) < radius:
		explode( null )


func _on_area_2d_area_entered( area: Area2D ) -> void:
	var grand_parent = area.get_parent().get_parent()
	if grand_parent.is_in_group( "RAF_Tank" ):
		explode( grand_parent )
