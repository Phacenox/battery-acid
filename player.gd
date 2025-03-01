extends CharacterBody2D

func _process(delta):
	move(delta)

var dead = false
func kill(gibbed = false):
	for r in get_children():
		if r.name == "batterylight":
			r.queue_free()
	if gibbed:
		var g = gibs.instantiate()
		add_child(g)
		g.atlas_coords = Vector2i(4, 0)
		g.break_block()
		g.position = Vector2.ZERO
		$pivot.visible = false
		forward_v = sign(forward_v) * max(5, abs(forward_v))
		boost_speed = 0
		collision_mask = 0
	if dead: return
	var game = get_tree().get_first_node_in_group('Game')
	game.get_node("CanvasLayer/GameOver").visible = true
	var t1 = create_tween()
	t1.tween_property(game.get_node("CanvasLayer/GameOver"), "modulate", Color.WHITE, 2).set_delay(2)
	dead = true
	collision_layer = 0
	$Bubbles.emitting = false
	var t = create_tween()
	t.tween_property($PointLight2D, "energy", 0, 3.5)

var forward_v = 0.0
@export
var accel = 20
@export
var decel = 20
@export
var max_v = 60
@export
var turn_speed: float = 1
@export
var wall_max_speed = 15
@export
var wall_break_speed = 45
@export
var boost: Curve
@export
var turn_strength: Curve
@export
var camera: Camera2D
var force_up = false
func move(delta):
	var last_position = position
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if force_up: input_dir = Vector2.UP
	if dead: input_dir = Vector2.ZERO
	if(!input_dir.is_zero_approx() && !Input.is_key_pressed(KEY_SHIFT)):
		forward_v = min(forward_v + accel * delta, max_v)
		if forward_v < 0:
			forward_v = -max(-forward_v - decel * delta, 0)
	else:
		forward_v = sign(forward_v) * max(abs(forward_v) - decel * delta, 0)
	if(!input_dir.is_zero_approx()):
		turn_towards(input_dir, turn_speed * delta * turn_strength.sample((forward_v + extra_speed) / (max_v + boost_speed)))
	velocity = $pivot.transform.x * (forward_v + extra_speed)
	velocity += bump_extra
	move_and_slide()
	if boosting && extra_speed > wall_break_speed:
		var collision = get_last_slide_collision()
		if collision is KinematicCollision2D:
			collision.get_collider_shape_index()
			var layer = collision.get_collider()
			if layer is TileMapLayer:
				break_cell(layer, collision.get_collider_rid())
				forward_v = -max_v
				boosting = false
				$ASM_hurt.play()
	if forward_v > wall_max_speed:
		forward_v = velocity.length() - extra_speed
	camera.offset += (position - last_position) * 0.0015

func _input(event):
	if dead: return
	if event is InputEventKey:
		if event.keycode == KEY_SPACE && !event.is_echo():
			if event.is_pressed():
				do_boost()
func break_cell(layer: TileMapLayer, body_rid):
	layer.get_parent().get_parent().try_destroy_tile_at(body_rid, 2)
	ui.hurt(50)

func turn_towards(to, delta):
	var theta = wrapf(atan2(to.y, to.x) - $pivot.rotation, -PI, PI)
	$pivot.rotation += clamp(delta, 0, abs(theta)) * sign(theta)

var boosting = false
@export
var boost_speed = 40
@export
var boost_length = 2.0
var extra_speed = 0.0
@export
var boost_cost = 25
var boost_coroutine
var boost_x = 0
func do_boost():
	$ASM_fllow.play()
	boost_x = 0
	if boosting:
		return
	boosting = true
	while(boost_x < boost_length && boosting):
		await get_tree().process_frame
		var delta = get_process_delta_time()
		boost_x += delta
		extra_speed = boost.sample(boost_x / boost_length) * boost_speed
		if extra_speed > 10:
			ui.charge -= delta * boost_cost / boost_length
	extra_speed = 0
	boosting = false
@onready
var ui = get_tree().get_first_node_in_group("ui")

@export
var bump_strength = 30
@export
var bump_decel = 16
var bump_extra = Vector2.ZERO
func bump(direction: Vector2):
	var t = bump_strength
	while t > 0:
		await get_tree().process_frame
		t -= get_process_delta_time() * bump_decel
		bump_extra = t * direction
	bump_extra = Vector2.ZERO

@export
var gibs: PackedScene