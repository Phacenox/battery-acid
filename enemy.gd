extends CharacterBody2D

@export
var segments: Array[Node2D]


func _process(delta):
	doMovement(delta)
	var prev = self
	for seg in segments:
		seg.global_position = prev.global_position + (seg.global_position - prev.global_position).normalized() * 10
		seg.look_at(prev.global_position)
		prev = seg

var target
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

@export
var pathing_rngfind = 5.0

@onready
var player = get_tree().get_first_node_in_group("Player")

var dead = false
func die():
	$PointLight2D4.enabled = false
	stunned = INF
	dead = true
	$head.set_script(null)

func try_find_new_rest_area():
	var rand_vec = Vector2.RIGHT.rotated(randf_range(0, 2*PI)) * randf_range(1, pathing_rngfind) * 16
	var tiles = (get_tree().get_first_node_in_group("Game").current_level.get_node("Zone/TileMapLayer")as TileMapLayer)
	var coords = tiles.local_to_map(tiles.to_local(global_position + rand_vec))
	if coords.x < 0 || coords.x > 16*6 || coords.y < 0 || coords.y > 16*3:
		return
	if tiles.get_cell_atlas_coords(coords) == -Vector2i.ONE:
		#tile's empty. good, now raycast
		var ray = PhysicsRayQueryParameters2D.create(global_position, global_position + rand_vec)
		var result = get_world_2d().direct_space_state.intersect_ray(ray)
		if result:
			#print("nope! blocked")
			return
		cruising = false
		resting = randf_range(rest_time_min, rest_time_max)
		target = tiles.to_global(tiles.map_to_local(coords) + Vector2.ONE * 8)
		#print("going to " + str(tiles.to_global(tiles.map_to_local(coords) + Vector2.ONE * 8)))

func doMovement(delta):
	var input_dir = target - global_position if target != null else Vector2.ZERO

	if !cruising && input_dir.length_squared() < cruise_distance:
		cruising = true
	if player_valid && !dead && !chasing && stunned <= 0 && !player.dead && (player.global_position - global_position).length_squared() < 4000:
		var result = get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position, player.global_position, 34294967295, [get_rid()]))
		if not result || result["collider"].name == "Player":
			chasing = true
			$head.sees_player = true
			$ASM_yell.play()
	max_speed = cruising_speed if cruising else search_speed
	max_turnrate = cruising_turning if cruising else search_turning
	if !dead && chasing:
		input_dir = player.global_position - global_position
		if input_dir.length_squared() > 10000 || player.dead:
			chasing = false
			$head.sees_player = false
			cruising = true
		max_speed = chasing_speed
		max_turnrate = chasing_turning

	if stunned <= 0 && !dead:
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
			$ASM_hurt.volume_db = -10
			if chasing:
				break_cell(layer, collision.get_collider_rid())
				$ASM_hurt.volume_db = -6
			elif !cruising:
				cruising = true
			$ASM_hurt.play()
			forward_v = -cruising_speed
			stunned = randf_range(2, 5)
	if cruising:
		resting -= delta
	if resting <= 0 && cruising:
		try_find_new_rest_area()
		#find new destination

var health = 5
func break_cell(layer: TileMapLayer, body_rid):
	layer.get_parent().get_parent().try_destroy_tile_at(body_rid, 2)
	health -= 1
	if health <= 0:
		die()

func turn_towards(to, delta):
	var theta = wrapf(atan2(to.y, to.x) - $head.rotation, -PI, PI)
	$head.rotation += clamp(delta, 0, abs(theta)) * sign(theta)

var player_valid = true
func forget_player():
	player_valid = false
	if chasing:
		chasing = false
		$head.sees_player = false
		cruising = true
func allow_target_player():
	player_valid = true
