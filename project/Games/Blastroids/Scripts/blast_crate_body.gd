extends RigidBody2D
class_name BlastCrateBody


const CRATE_PICKUPS: Array = [
	"bomb",
	"spread",
	"charge",
	"mass",
	"missile", "missile", "missile", "missile"
]


var clones: Array = []
var minimap_clones: Array = []
var hit_points: float = 500.0
var last_hit_points: float = 500.0
var max_hit_points: float = 500.0
var num_cracks: float = 20.0
var game: BlastGame
var is_destroyed: bool = false
var rect: Rect2
var img: Image
var texture: ImageTexture
var weapon: String
var is_max_count: bool = false


@onready var sprite: Sprite2D = $Sprite2D


func init( new_game: BlastGame, set_weapon: String = "" ) -> void:
	if set_weapon == "":
		weapon = CRATE_PICKUPS.pick_random()
	else:
		weapon = set_weapon
	rect = Rect2( 0, 0, img.get_width(), img.get_height() )
	game = new_game
	for i in range( game.worlds.size() ):
		
		# Create clone
		var world = game.worlds[ i ]
		var clone_crate: BlastCrate = game.scenes.CRATE.instantiate()
		world.add_child( clone_crate )
		clone_crate.sprite.texture = sprite.texture
		clones.append( clone_crate )
		
		# Create minimap clone
		var minimap = game.minimaps[ i ]
		var mini_clone: Sprite2D = Sprite2D.new()
		mini_clone.scale = Vector2( 2, 2 )
		mini_clone.texture = sprite.texture
		mini_clone.material = game.create_minimap_material( Color.DIM_GRAY )
		minimap.add_child( mini_clone )
		minimap_clones.append( mini_clone )


func hit( damage: float, fired_from: BlastShipBody ) -> void:
	if is_destroyed:
		return
	for clone: BlastCrate in clones:
		clone.hit_sounds.pick_random().play()
	hit_points -= damage
	draw_damage()
	if hit_points <= 0:
		if fired_from != null:
			fired_from.stats.crate_kills += 1
		destroy()


func burn( damage: float ) -> void:
	if is_destroyed:
		return
	hit_points -= damage
	for clone: BlastCrate in clones:
		if not clone.burn_sound.playing:
			clone.burn_sound.play()
	if hit_points <= 0:
		destroy( true )


func draw_damage() -> void:
	var cracks = roundi( ( ( last_hit_points - hit_points ) / max_hit_points ) * num_cracks )
	if cracks == 0:
		return
	for i in range( cracks ):
		Globals.draw_cracks( img, [ Color( 1, 1, 1, 1 ), Color( 0.9, 0.9, 0.9, 1 ) ] )
	last_hit_points = hit_points
	if texture == null:
		texture = ImageTexture.create_from_image( img )
		sprite.texture = texture
		for clone: BlastCrate in clones:
			clone.sprite.texture = texture
	sprite.texture.update( img )


func destroy( is_burned: bool = false) -> void:
	if is_destroyed:
		return
	is_destroyed = true
	if not is_burned:
		for clone: BlastCrate in clones:
			clone.explode_sound.play()
	var num_explosions = 10
	var exp_size = 1.5
	var duration = num_explosions * 0.1 + 0.1
	var tween = create_tween()
	tween.tween_property( sprite, "modulate:a", 0.8, duration / 2 )
	tween.tween_property( sprite, "modulate:a", 0.0, duration / 2 )
	is_destroyed = true
	var radius = sqrt( rect.size.x * rect.size.x + rect.size.y * rect.size.y ) * 0.5
	await game.create_explosions( num_explosions, radius, self, exp_size )
	set_collision_layer_value( 1, false )
	if not is_burned:
		breakup_crate()
	freeze = true
	await get_tree().physics_frame
	if tween.is_running():
		await tween.finished
	await get_tree().physics_frame
	for clone in clones:
		clone.queue_free()
	for clone in minimap_clones:
		clone.queue_free()
	clones = []
	minimap_clones = []
	queue_free()


func breakup_crate() -> void:
	# Create energy pickups
	var count = maxi( randi_range( -3, 12 ), 3 )
	game.create_pickups( position, linear_velocity, count, 50.0, 20.0 )
	
	# Create Weapon Pickup
	var weapon_data = BlastGame.WEAPONS_DATA[ weapon ]
	count = 1
	if weapon_data.has( "COUNT" ):
		var min_count = roundi( float( weapon_data.COUNT ) / 2 )
		count = maxi( randi_range( -min_count, weapon_data.COUNT ), min_count )
	if is_max_count:
		count = weapon_data.COUNT
	var base_move: float = 20.0
	var base_push: float = 50.0
	if count == 1:
		base_push = 0
		base_move = 0
	game.create_weapon_pickup( position, linear_velocity, count, base_push, base_move, weapon )


func get_clones() -> Array:
	return clones


func _ready() -> void:
	img = sprite.texture.get_image()
	await get_tree().create_timer( 0.1 ).timeout
	set_collision_layer_value( 1, true )


func _physics_process( _delta: float ) -> void:
	for clone: BlastCrate in clones:
		clone.sprite.modulate = sprite.modulate
		clone.rotation = rotation
		clone.position = position
	for clone in minimap_clones:
		clone.rotation = rotation
		clone.position = position
