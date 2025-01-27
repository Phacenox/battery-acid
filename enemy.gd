extends CharacterBody2D


func _physics_process(_delta):
	move_and_slide()

@export
var segments: Array[Node2D]


func _process(delta):
	doMovement(delta)
	var prev = self
	for seg in segments:
		seg.global_position = prev.global_position + (seg.global_position - prev.global_position).normalized() * 10
		seg.look_at(prev.global_position)
		prev = seg
@onready
var target: Vector2 = self.global_position
@export
var cruising_speed = 20.0
@export
var cruising_turning = 2.0
@export
var search_speed = 45.0
@export
var search_turning = 5.0
@export
var chasing_speed = 30
@export
var chasing_turning = 5.0
@export
var cruise_distance = 5.0
@export
var accel = 40
var sees_player = false
var forward_v = 0
var turn_rate = 0
var stunned = 0
var resting = 0
var rest_time_min = 1.5
var rest_time_max = 3
var cruising = false
var chasing = false

var max_speed = 0.0
var max_turnrate = 0.0

@onready
var player = get_tree().get_first_node_in_group("Player")

func doMovement(delta):
	var input_dir = target - global_position if target != null else Vector2.ZERO

	if !cruising && input_dir.length_squared() < cruise_distance:
		cruising = true
	if !chasing && !player.dead && (player.global_position - global_position).length_squared() < 4000:
		if not get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position, player.global_position)).has("name"):
			chasing = true
			$head.sees_player = true
	max_speed = cruising_speed if cruising else search_speed
	max_turnrate = cruising_turning if cruising else search_turning
	if(chasing):
		input_dir = player.global_position - global_position
		if input_dir.length_squared() > 10000 || player.dead:
			chasing = false
			$head.sees_player = false
		max_speed = chasing_speed
		max_turnrate = chasing_turning

	if stunned <= 0:
		forward_v = lerpf(forward_v, max_speed, delta * accel)
	else:
		forward_v = lerpf(forward_v, 0, delta * accel/2)

	stunned -= delta
	
	if(stunned <= 0 && !input_dir.is_zero_approx()):
		turn_towards(input_dir, max_turnrate * delta)
		
	velocity = $head.transform.x * forward_v
	move_and_slide()
	
	var collision = get_last_slide_collision()
	if forward_v > 0 && collision is KinematicCollision2D:
		collision.get_collider_shape_index()
		var layer = collision.get_collider()
		if layer is TileMapLayer:
			break_cell(layer, collision.get_collider_rid())
			forward_v = -cruising_speed
			stunned = 2
	if cruising:
		resting -= delta
	if resting <= 0 && cruising:
		cruising = false
		resting = randf_range(rest_time_min, rest_time_max)
		target = Vector2(randf_range(0, 20*16), randf_range(0, -20*16))
		#find new destination

func break_cell(layer, body_rid):
	layer.set_cell(layer.get_coords_for_body_rid(body_rid), 0)

func turn_towards(to, delta):
	var theta = wrapf(atan2(to.y, to.x) - $head.rotation, -PI, PI)
	$head.rotation += clamp(delta, 0, abs(theta)) * sign(theta)