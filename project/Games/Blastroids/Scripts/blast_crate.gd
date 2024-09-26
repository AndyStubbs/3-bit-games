extends Node2D
class_name BlastCrate


var hit_sounds: Array


@onready var sprite = $Sprite2D
@onready var hit_sound = $Sounds/Hit
@onready var hit_sound2 = $Sounds/Hit2
@onready var burn_sound = $Sounds/BurnSound
@onready var explode_sound = $Sounds/Explode


func _ready() -> void:
	hit_sounds = [ hit_sound, hit_sound2 ]
