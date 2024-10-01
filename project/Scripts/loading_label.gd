extends Label


const MSG = "TR_LOADING"
const DELAY = 0.15


var t: float = DELAY
var dots: String = "..."


func _ready() -> void:
	text = tr( MSG ) + dots

func _process( delta: float ) -> void:
	t -= delta
	if t < 0:
		t = DELAY
		dots += "."
		if dots.length() > 3:
			dots = ""
		text = tr( MSG ) + dots.rpad( 3 )
