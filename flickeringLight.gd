@tool
extends PointLight2D


var delay = 0.1

@export
var lightenergy = 1.0

func _process(delta):
	delay -= delta
	if(delay <= 0):
		delay = remap(randf(), 0, 1, 0.05, 0.15)
		energy = delay * 15 * lightenergy
