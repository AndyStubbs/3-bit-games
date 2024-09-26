extends Node2D
class_name BlastMissile


@onready var sprite: Sprite2D = $Sprite2D
@onready var rocket: Node2D = $Rocket
@onready var marker: Sprite2D = $Sprite2D/Sprite2D
@onready var rocket_sound: AudioStreamPlayer2D = $Sounds/RocketSound
@onready var explode_sound: AudioStreamPlayer2D = $Sounds/ExplodeSound
@onready var explode_sound2: AudioStreamPlayer2D = $Sounds/ExplodeSound2
