extends RefCounted
class_name RAF_Level


var width: int = 0
var height: int = 0
var heights: Array = []
var rock_heights: Array = []
var img: Image
var rock_img: Image
var rock_mask: Image
var rect: Rect2i
var scale: float = 4
var gravity: Vector2 = Vector2( 0, 9.8 )
var wind: Vector2 = Vector2( 0, 0 )
var explosions: Array = []
var ammo: Array = []
var tanks: Array = []
var scores: Array = []
var points_tracker: Array = []


@warning_ignore( "unused_signal" )
#signal on_explosion( point: Vector2, force: float, radius: float, points: int )
signal on_explosion( explosion: RAF_Explosion )

@warning_ignore( "unused_signal" )
signal on_heights_updated()

@warning_ignore( "unused_signal" )
signal on_turn_ended( delay: float )

@warning_ignore( "unused_signal" )
signal on_particle_landed( pos: Vector2, color: Color, pattern: String )

@warning_ignore( "unused_signal" )
signal on_bridge_landed( pos: Vector2, vel: Vector2 )

@warning_ignore( "unused_signal" )
signal on_shovel_landed( pos: Vector2, vel: Vector2 )

@warning_ignore( "unused_signal" )
signal on_laser_fired( start: Vector2i, end: Vector2i )

@warning_ignore( "unused_signal" )
signal on_bullet_spawned( bullet )

@warning_ignore( "unused_signal" )
signal on_bullet_destroyed()
