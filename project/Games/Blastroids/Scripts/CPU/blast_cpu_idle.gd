extends RefCounted
class_name BlastCpuIdle


var cpu: BlastCpuAi
var ship: BlastShipBody


func init( new_cpu: BlastCpuAi ) -> void:
	cpu = new_cpu
	ship = cpu.ship


func start( _data: Variant ) -> void:
	pass


func process( delta: float ) -> void:
	var attack_chance: float = 0.75
	
	# If low on laser energy then lower chance of attack
	if ship.laser_energy < ship.weapon_data.DRAIN * delta:
		attack_chance = 1.0
	elif ship.laser_energy / ship.max_laser_energy < 0.5:
		attack_chance = 0.9
	
	# Look for random targets
	if randf_range( 0, 1 ) > attack_chance and ship.nearby_objs.size() > 0:
		var target = ship.nearby_objs.pick_random()
		cpu.set_state( cpu.STATE.ATTACK, target )
		return
	
	# Pick a random position to move
	var pos = Vector2(
		ship.position.x + randf_range( -500, 500 ),
		ship.position.y + randf_range( -500, 500 )
	)
	# Check for collisions
	var collider = ship.shapecast_2d( pos )
	if collider:
		return
	
	# No collisions so just move to a random position
	cpu.set_state( cpu.STATE.MOVE, pos )
