extends RigidBody2D
class_name BlastRockBody


const DATA = {
	"huge": {
		"exp_size": 4.0,
		"exp_num": 20,
		"break_num": 16,
		"hit_points": 1000,
		"move": 60,
		"push": 80
	},
	"large": {
		"exp_size": 2.0,
		"exp_num": 12,
		"break_num": 8,
		"hit_points": 500,
		"move": 40,
		"push": 80
	},
	"medium": {
		"exp_size": 1.5,
		"exp_num": 10,
		"break_num": 4,
		"hit_points": 300,
		"move": 30,
		"push": 100
	},
	"small": { 
		"exp_size": 1.0,
		"exp_num": 8,
		"break_num": 2,
		"hit_points": 150,
		"move": 15,
		"push": 120
	},
	"tiny": {
		"exp_size": 0.9,
		"exp_num": 6,
		"break_num": 0,
		"hit_points": 50,
		"move": 10,
		"push": 150
	}
}


@export var rock_size: String = "medium"


var rock_width: float = 50.0
var rock_height: float = 50.0
var clones: Array = []
var minimap_clones: Array = []
var max_hit_points: float = 10.0
var hit_points: float = 10.0
var num_cracks: float = 10.0
var last_hit_points: float = 10.0
var game: BlastGame
var is_destroyed: bool = false
var rect: Rect2
var img: Image
var texture: ImageTexture
var is_energy_dense: bool = false
var energy_dense_chance: float = 0.1
var energy_tween: Tween
var is_loaded: bool = false
var shape_cast: ShapeCast2D


@onready var poly: CollisionPolygon2D = $CollisionPolygon2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_sound: AudioStreamPlayer = $Sounds/Hit
@onready var hit_sound2: AudioStreamPlayer = $Sounds/Hit2
@onready var burn_sound: AudioStreamPlayer = $Sounds/Burn
@onready var explode_sound: AudioStreamPlayer = $Sounds/Explode


func init( new_game: BlastGame ) -> void:
	is_energy_dense = randf_range( 0, 1 ) > 1.0 - energy_dense_chance
	if is_energy_dense:
		sprite.modulate = Color( 0.3, 0.5, 0.9 )
	game = new_game
	for i in range( game.worlds.size() ):
		var world = game.worlds[ i ]
		var minimap = game.minimaps[ i ]
		var clone_rock: Sprite2D = Sprite2D.new()
		var minimap_clone: Sprite2D = Sprite2D.new()
		clone_rock.texture = sprite.texture
		minimap_clone.scale = Vector2( 2, 2 )
		minimap_clone.texture = sprite.texture
		minimap_clone.material = game.create_minimap_material( Color.GRAY )
		world.add_child( clone_rock )
		minimap.add_child( minimap_clone )
		clones.append( clone_rock )
		minimap_clones.append( minimap_clone )


func load_rock() -> void:
	var rock_id = str( Blast.rock_names[ rock_size ].pick_random() )
	var file_name = "res://Games/Blastroids/Rocks/" + rock_size + "/rock-" + rock_id
	var load_file = FileAccess.open( file_name + ".json", FileAccess.READ )
	var json_string = load_file.get_as_text()
	var data = JSON.parse_string( json_string )
	load_file.close()
	rock_width = data.width
	rock_height = data.height
	var min_x = INF
	var min_y = INF
	var max_x = 0
	var max_y = 0
	var points: PackedVector2Array = PackedVector2Array()
	for point: Array in data.points:
		var vec = Vector2( point[ 0 ], point[ 1 ] )
		if vec.x < min_x:
			min_x = vec.x
		if vec.x > max_x:
			max_x = vec.x
		if vec.y < min_y:
			min_y = vec.y
		if vec.y > max_y:
			max_y = vec.y
		points.append( vec )
	rect = Rect2( min_x, min_y, max_x, max_y )
	poly.polygon = points
	poly.position = Vector2( -rock_width / 2, -rock_height / 2 )
	sprite.texture = load( file_name + ".png" )
	img = sprite.texture.get_image()
	is_loaded = true
	shape_cast = $ShapeCast2D
	if rock_width > rock_height:
		shape_cast.shape.radius = rock_width / 2
	else:
		shape_cast.shape.radius = rock_height / 2


func calc_mass() -> void:
	mass = max( ( rock_width * rock_height ) / 300, 5 )


func hit( damage: float, fired_from: BlastShipBody ) -> void:
	if is_destroyed:
		return
	if not hit_sound.playing:
		hit_sound.play()
	elif not hit_sound2.playing:
		hit_sound2.play()
	hit_points -= damage
	draw_damage()
	if hit_points <= 0:
		if fired_from != null:
			fired_from.stats.asteroid_kills += 1
		destroy()


func burn( damage: float ) -> void:
	if is_destroyed:
		return
	hit_points -= damage
	if not burn_sound.playing:
		burn_sound.play()
	if hit_points <= 0:
		destroy( true )


func draw_damage() -> void:
	var cracks = roundi( ( ( last_hit_points - hit_points ) / max_hit_points ) * num_cracks )
	if cracks == 0:
		return
	for i in range( cracks ):
		Globals.draw_cracks( img, [ Color( 0.1, 0.1, 0.1, 0.5 ), Color( 0.3, 0.3, 0.3, 0.5 ) ] )
	last_hit_points = hit_points
	if texture == null:
		texture = ImageTexture.create_from_image( img )
		sprite.texture = texture
		for clone in clones:
			clone.texture = texture
	sprite.texture.update( img )


func destroy( is_burned: bool = false ) -> void:
	if is_destroyed:
		return
	if not is_burned:
		explode_sound.play()
	var num_explosions = DATA[ rock_size ].exp_num
	var exp_size = DATA[ rock_size ].exp_size
	var duration = num_explosions * 0.1 + 0.1
	var tween = create_tween()
	tween.tween_property( sprite, "modulate:a", 0.8, duration / 2 )
	tween.tween_property( sprite, "modulate:a", 0.0, duration / 2 )
	is_destroyed = true
	var radius = sqrt( rect.size.x * rect.size.x + rect.size.y * rect.size.y ) * 0.5
	await game.create_explosions( num_explosions, radius, self, exp_size )
	set_collision_layer_value( 1, false )
	set_collision_mask_value( 1, false )
	if not is_burned:
		breakup_rock()
	await get_tree().physics_frame
	if tween.is_running():
		await tween.finished
	await get_tree().physics_frame
	for clone in clones:
		clone.queue_free()
	for clone in minimap_clones:
		clone.queue_free()
	queue_free()


func breakup_rock() -> void:
	var num = DATA[ rock_size ].break_num
	var new_rocks = []
	while num > 0:
		var rock: BlastRockBody = BlastGame.ROCK_SCENE.instantiate()
		if num > 8 and randf_range( 0, 1.0 ) > 0.5:
			rock.rock_size = "large"
			num -= 8
		elif num > 4 and randf_range( 0, 1.0 ) > 0.5:
			rock.rock_size = "medium"
			num -= 4
		elif num > 2 and randf_range( 0, 1.0, ) > 0.35:
			rock.rock_size = "small"
			num -= 2
		else:
			rock.rock_size = "tiny"
			num -= 1
		new_rocks.append( rock )
	var da = TAU / new_rocks.size()
	var a = TAU * randf_range( 0, 1 )
	var base_move = DATA[ rock_size ].move
	for rock in new_rocks:
		var data = DATA[ rock.rock_size ]
		var push = Vector2.from_angle( randf_range( a, a + da / 2 ) ) * data.push
		var move = Vector2.from_angle( randf_range( a, a + da / 2  ) ) * base_move
		if is_energy_dense:
			rock.energy_dense_chance = 0.5
		rock.linear_velocity = linear_velocity + push * randf_range( 0.6, 1.0 )
		rock.position = position + move
		rock.set_collision_layer_value( 1, false )
		game.add_body( rock )
		rock.init( game )
		a += da
	
	# Random chance of generating a pickup
	if is_energy_dense or randf_range( 0, 1 ) > 0.5:
		var count = maxi( randi_range( -5, 5 ), 1 )
		if is_energy_dense:
			count += maxi( randi_range( -3, 3 ), 1 )
		game.create_pickups( position, linear_velocity, count, 100, base_move )


func get_clones() -> Array:
	return clones


func _ready() -> void:
	hit_points = DATA[ rock_size ].hit_points
	last_hit_points = hit_points
	max_hit_points = hit_points
	if not is_loaded:
		load_rock()
	calc_mass()
	await get_tree().create_timer( 0.1 ).timeout
	set_collision_layer_value( 1, true )
	set_collision_mask_value( 1, true )


func _physics_process( _delta: float ) -> void:
	if is_energy_dense:
		if energy_tween == null or not energy_tween.is_running():
			energy_tween = create_tween()
			energy_tween.tween_property( sprite, "modulate:h", randf_range( 0.4, 0.9 ), 1.0 )
	for clone: Sprite2D in clones:
		clone.modulate = sprite.modulate
		clone.rotation = rotation
		clone.position = position
	for clone: Sprite2D in minimap_clones:
		clone.modulate = sprite.modulate
		clone.rotation = rotation
		clone.position = position
