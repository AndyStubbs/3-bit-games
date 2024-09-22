extends Label


const MAX_OFFSET_X: int = 50
const MIN_OFFSET_X: int = 20


@export var offset: Vector2
@export var tank: RAF_Tank
@export var score: int:
	set( value ):
		score = value
		if value > 0:
			text = "+" + str( value )
			modulate = Color.WHITE
		else:
			text = str( value )
			modulate = Color.RED
@export var start_pos: Vector2


var level: RAF_Level


func init( new_level: RAF_Level ) -> void:
	level = new_level
	level.points_tracker.append( self )
	if score < 0:
		modulate = Color.RED
	global_position = start_pos
	offset.x += tank.score_label_count * 100
	global_position.x += tank.score_label_count * 100
	tank.score_label_count += 1
	
	# Fade in
	modulate.a = 0
	
	var tween1 = create_tween()
	tween1.tween_property( self, "modulate:a", 1.0, 0.35 )
	await tween1.finished
	
	# Move to scoreboard
	var tween2 = create_tween()
	tween2.tween_property( self, "global_position", offset, 0.75 ).set_trans( Tween.TRANS_CUBIC )
	await tween2.finished
	
	$TickSound.play()
	
	# Add to scoreboard
	var d = 1 * sign( score )
	while score != 0:
		var factor = 1
		if score > 1000:
			factor = 100
		elif score > 100:
			factor = 20
		elif score > 50:
			factor = 5
		elif score > 10:
			factor = 2
		var change = d * factor
		score -= change
		tank.score += change
		if not is_inside_tree():
			return
		await get_tree().physics_frame
	$TickSound.stop()
	
	# Fade Out
	var tween4 = create_tween()
	tween4.tween_property( self, "modulate:a", 0.0, 0.5 )
	await tween4.finished
	
	tank.score_label_count -= 1
	level.points_tracker.erase( self )
	queue_free()
