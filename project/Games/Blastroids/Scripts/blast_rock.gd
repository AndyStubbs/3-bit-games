extends Node2D
class_name BlastRock


var hit_sounds: Array


@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_sound: AudioStreamPlayer2D = $Sounds/Hit
@onready var hit_sound2: AudioStreamPlayer2D = $Sounds/Hit2
@onready var burn_sound: AudioStreamPlayer2D = $Sounds/Burn
@onready var explode_sound: AudioStreamPlayer2D = $Sounds/Explode


func _ready() -> void:
	hit_sounds = [ hit_sound, hit_sound2 ]
