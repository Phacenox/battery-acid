extends Camera2D

@export
var debuglight: DirectionalLight2D
@export
var speed = 200.0

var screen_shake = 0
@export
var shake_amount = 2

var active = false
func _process(delta):
	if(active):
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		position += input_dir * speed * delta
	else:
		position = shake_amount * screen_shake * Vector2.RIGHT.rotated(randf_range(0, 2*PI))
		screen_shake = max(0, screen_shake - delta)
	

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_F1 && event.pressed:
			active = !active
			debuglight.editor_only = !active
			if !active:
				position = Vector2.ZERO