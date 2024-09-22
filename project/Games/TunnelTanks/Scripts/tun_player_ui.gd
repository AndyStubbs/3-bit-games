extends Control
class_name TUN_PlayerUI


const BAR_ROUND = 2.5


var player_tank: TUN_Tank


@onready var energy_bar = $HB/TextureRect/EnergyBar
@onready var shields_bar = $HB/TextureRect/ShieldBar
@onready var score_label: Label = $HB/Panel/ScoreText


func _ready() -> void:
	Tun.on_energy_changed.connect( on_energy_changed )
	Tun.on_shields_changed.connect( on_shields_changed )
	Tun.on_score_changed.connect( on_score_changed )


func on_energy_changed( tank: TUN_Tank ) -> void:
	if tank == player_tank:
		energy_bar.value = roundf( tank.energy / BAR_ROUND ) * BAR_ROUND


func on_shields_changed( tank: TUN_Tank ) -> void:
	if tank == player_tank:
		shields_bar.value = roundf( tank.shields / BAR_ROUND ) * BAR_ROUND


func on_score_changed( tank: TUN_Tank ) -> void:
	if tank == player_tank:
		score_label.text = str( tank.score )
