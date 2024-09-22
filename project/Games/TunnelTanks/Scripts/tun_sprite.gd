extends Sprite2D


@export var sprite_type: Tun.SPRITE_TYPES = Tun.SPRITE_TYPES.BACKGROUND


func _ready() -> void:
	Tun.on_sprite_ready.emit( self, sprite_type )
