extends Node2D

var tweens
var is_open = false

func open():
	if !is_open:
		$ASM_gate.play()
	is_open = true
	if tweens != null:
		for i in tweens:
			i.stop()
	var t1 = create_tween()
	t1.tween_property($top, "position", Vector2(74, -24), 3)
	var t2 = create_tween()
	t2.tween_property($bottom, "position", Vector2(-74, 24), 3)
	tweens = [t1, t2]

func close():
	if is_open:
		$ASM_gate.play()
	is_open = false
	$ASM_gate.play()
	if tweens != null:
		for i in tweens:
			i.stop()
	var t1 = create_tween()
	t1.tween_property($top, "position",  Vector2(0, -24), 3)
	var t2 = create_tween()
	t2.tween_property($bottom, "position",  Vector2(0, 24), 3)
	tweens = [t1, t2]