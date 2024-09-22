extends Node2D
class_name RAF_Explosion


@export var radius: float = 7
@export var force: float = 5000
@export var points: int = 50
@export var fired_from: RAF_Tank


var level: RAF_Level
var hits: Array = []
var is_nuke: bool = false
var is_nuke2: bool = false
var is_potion: bool = false
var is_main_bullet: bool = true


@onready var visuals: Node2D = $Visuals
@onready var nuke: Node2D = $Nuke
@onready var nuke2: Node2D = $Nuke2
@onready var potion: Node2D = $Potion


func _ready() -> void:
	var lifetime: float = 0
	var boom
	var db = 0.0
	if not is_main_bullet:
		db -= 12
	if is_nuke:
		boom = nuke
		$BigExplosionSound.volume_db = db
		$BigExplosionSound.play()
	elif is_nuke2:
		boom = nuke2
		$BigExplosionSound.volume_db = db + 6.0
		$BigExplosionSound.play()
	elif is_potion:
		boom = potion
		$GlassBreakSound.volume_db = db - 6.0
		$GlassBreakSound.play()
	else:
		boom = visuals
		$ExplosionSound.volume_db = db
		$ExplosionSound.play()
	for v: GPUParticles2D in boom.get_children():
		v.emitting = true
		if v.lifetime > lifetime:
			lifetime = v.lifetime
	lifetime += 0.5
	explode()
	await get_tree().create_timer( lifetime ).timeout
	queue_free()


func init( new_level: RAF_Level, tank_source: RAF_Tank ) -> void:
	level = new_level
	fired_from = tank_source


func explode() -> void:
	var pos: Vector2i = Vector2i(
		roundi( global_position.x / level.scale ),
		roundi( position.y / level.scale )
	)
	if pos.x >= 0 and pos.x < level.width:
		if not is_potion:
			level.explosions.append( {
				"pos": pos,
				"radius": radius
			} )
		level.on_explosion.emit( self )
