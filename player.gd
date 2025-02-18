extends CharacterBody2D

func _process(delta):
    if dead: return
    move(delta)

var dead = false
func kill(gibbed = false):
    dead = true
    $CollisionShape2D.disabled = true
    if gibbed:
        $pivot.queue_free()
    $Bubbles.queue_free()
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
func move(delta):
    var last_position = position
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if(!input_dir.is_zero_approx() && !Input.is_key_pressed(KEY_SHIFT)):
        forward_v = min(forward_v + accel * delta, max_v)
        if forward_v < 0:
            forward_v = -max(-forward_v - decel * delta, 0)
    else:
        forward_v = sign(forward_v) * max(abs(forward_v) - decel * delta, 0)
    if(!input_dir.is_zero_approx()):
        turn_towards(input_dir, turn_speed * delta * turn_strength.sample((forward_v + extra_speed) / (max_v + boost_speed)))
    velocity = $pivot.transform.x * (forward_v + extra_speed)
    move_and_slide()
    if forward_v + extra_speed > wall_break_speed:
        var collision = get_last_slide_collision()
        if collision is KinematicCollision2D:
            collision.get_collider_shape_index()
            var layer = collision.get_collider()
            if layer is TileMapLayer:
                break_cell(layer, collision.get_collider_rid())
                forward_v = -max_v
                boosting = false
    if forward_v > wall_max_speed:
        forward_v = velocity.length() - extra_speed
    $Camera2D/TextureRect.offset += (position - last_position) * 0.0015

func _input(event):
    if dead: return
    if event is InputEventKey:
        if event.keycode == KEY_SPACE && !event.is_echo():
            if event.is_pressed():
                do_boost()
func break_cell(layer, body_rid):
    layer.set_cell(layer.get_coords_for_body_rid(body_rid), 0)
func turn_towards(to, delta):
    var theta = wrapf(atan2(to.y, to.x) - $pivot.rotation, -PI, PI)
    $pivot.rotation += clamp(delta, 0, abs(theta)) * sign(theta)

var boosting = false
@export
var boost_speed = 40
@export
var boost_length = 2.0
var extra_speed = 0.0
func do_boost():
    boosting = true
    var x = 0
    while(x < boost_length && boosting):
        await get_tree().process_frame
        x += get_process_delta_time()
        extra_speed = boost.sample(x / boost_length) * boost_speed
    extra_speed = 0