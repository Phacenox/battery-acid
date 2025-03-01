extends StaticBody2D

@export
var segments: Array[Node2D]


func _process(delta):
	doMovement(delta)
	var prev = self
	for seg in segments:
		seg.global_position = prev.global_position + (seg.global_position - prev.global_position).normalized() * 14
		seg.look_at(prev.global_position)
		prev = seg

var target
@export
var max_rubber_ditance = 5000
@export
var chasing_turning = 5.0
@export
var accel = 40.0
var sees_player = false
var forward_v = 0
var turn_rate = 0

var chasing: bool

var endsequence_active = false
var scream_cooldown = 0

@onready
var player = get_tree().get_first_node_in_group("Player")
func begin_chase_player():
	if endsequence_active:
		return
	exit_blocker.queue_free()
	$big_head.frame = 1
	$big_head/PointLight2D4.factor = 1
	$big_head/PointLight2D5.factor = 1
	endsequence_active = true
	$big_head.sees_player = true
	for restarea in get_tree().get_nodes_in_group("rest_area"):
		restarea.ending_sequence = true
	for i in range(1, len(cutscene_objects)):
		cutscene_objects[i].set_deferred("disabled", false)
	cutscene_objects[0].set_deferred("disabled", true)
var giving_up = false
var chasing_speed = 0
func doMovement(delta):
	if !endsequence_active:
		return
	var input_dir = player.global_position - global_position
	if player.dead || giving_up:
		input_dir = Vector2.DOWN
		collision_layer = 0
	elif scream_cooldown <= 0:
		get_tree().get_first_node_in_group("camera").screen_shake = 1.5
		$ASM_yell.play()
		scream_cooldown = randf_range(8, 12)
	else:
		scream_cooldown -= delta
	chasing_speed = max_speed_curve.sample(input_dir.length() / max_rubber_ditance)
	forward_v = lerpf(forward_v, chasing_speed, delta * accel)
	
	if(!input_dir.is_zero_approx()):
		turn_towards(input_dir, chasing_turning * delta)
		
	var collision = move_and_collide($big_head.transform.x * forward_v * delta, true)
	global_position += $big_head.transform.x * forward_v * delta
	if collision && collision.get_collider().name == "Player":
		collision.get_collider().kill(true)
		get_tree().get_first_node_in_group("Player").get_node("ASM_munch").play()
		get_tree().get_first_node_in_group("ui").hurt(100000)
	if forward_v > 0 && collision is KinematicCollision2D:
		collision.get_collider_shape_index()
		var layer = collision.get_collider()
		if layer is TileMapLayer:
			if break_cell(layer, collision.get_collider_rid()):
				forward_v -= 0.03
	$CollisionShape2D.rotation = $big_head.rotation + $big_head.jaw_l.rotation
	$CollisionShape2D2.rotation = $big_head.rotation - $big_head.jaw_l.rotation

func break_cell(layer: TileMapLayer, body_rid):
	return layer.get_parent().get_parent().try_destroy_tile_at(body_rid, 100)

func turn_towards(to, delta):
	var theta = wrapf(atan2(to.y, to.x) - $big_head.rotation, -PI, PI)
	$big_head.rotation += clamp(delta, 0, abs(theta)) * sign(theta)

@export
var max_speed_curve: Curve

var stunned = 0
var cruising_speed = 0

func _on_area_2d_body_entered(_body):
	if get_tree().get_first_node_in_group("ui").has_battery:
		begin_chase_player()

@export
var exit_blocker: StaticBody2D

@export
var cutscene_objects: Array[CollisionShape2D]
