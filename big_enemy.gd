extends CharacterBody2D

@export
var segments: Array[Node2D]

func _physics_process(delta):
	doMovement(delta)
	var prev = self
	for seg in segments:
		seg.global_position = prev.global_position + (seg.global_position - prev.global_position).normalized() * 14
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
var accel = 40.0
var sees_player = false
var forward_v = 0
var turn_rate = 0
var resting = 0
var rest_time_min = 4
var rest_time_max = 8
var cruising = false

var chasing: bool :
	get:
		return _chasing
	set(value):
		$CollisionShape2D.disabled = !value
		_chasing = value
var _chasing: bool = false
func _ready():
	chasing = false

var max_speed = 0.0
var max_turnrate = 0.0
var stunned = 0.0

@export
var pathing_rngfind = 5.0

@onready
var player = get_tree().get_first_node_in_group("Player")

func try_find_new_rest_area():
	var rand_vec = Vector2.RIGHT.rotated(randf_range(0, 2*PI)) * randf_range(1, pathing_rngfind) * 16
	var tiles = (get_tree().get_first_node_in_group("Game").current_level.get_node("Zone/TileMapLayer")as TileMapLayer)
	var coords = tiles.local_to_map(tiles.to_local(global_position + rand_vec))
	if coords.x < 0 || coords.x > 16*6 || coords.y < 0 || coords.y > 16*3:
		return
	if tiles.get_cell_atlas_coords(coords) == -Vector2i.ONE:
		#tile's empty.
		cruising = false
		resting = randf_range(rest_time_min, rest_time_max)
		target = tiles.to_global(tiles.map_to_local(coords) + Vector2.ONE * 8)
		#print("going to " + str(tiles.to_global(tiles.map_to_local(coords) + Vector2.ONE * 8)))

var yell_cd = 2
func doMovement(delta):
	var input_dir = target - global_position if target != null else Vector2.ZERO
	yell_cd -= delta
	if yell_cd <= 0:
		$ASM_yell.play()
		yell_cd = randf_range(10, 20)
	if !cruising && input_dir.length_squared() < cruise_distance:
		cruising = true
	if player_valid && !chasing && !player.dead && (player.global_position - global_position).length_squared() < 4000:
		chasing = true
		$ASM_yell.play()
		$head.sees_player = true
	max_speed = cruising_speed if cruising else search_speed
	max_turnrate = cruising_turning if cruising else search_turning
	if chasing:
		input_dir = player.global_position - global_position
		if input_dir.length_squared() > 15000:
			chasing = false
			$head.sees_player = false
			cruising = true
		max_speed = chasing_speed
		max_turnrate = chasing_turning

	forward_v = lerpf(forward_v, max_speed, delta * accel)
	
	if(!input_dir.is_zero_approx()):
		turn_towards(input_dir, max_turnrate * delta)
		
	velocity = $head.transform.x * forward_v
	move_and_slide()
	
	var collision = get_last_slide_collision()
	if forward_v > 0 && collision is KinematicCollision2D:
		collision.get_collider_shape_index()
		var layer = collision.get_collider()
		if layer is TileMapLayer:
			if chasing:
				if break_cell(layer, collision.get_collider_rid()):
					forward_v -= 3
	if cruising:
		resting -= delta
	if resting <= 0 && cruising:
		try_find_new_rest_area()
		#find new destination

func break_cell(layer: TileMapLayer, body_rid):
	return layer.get_parent().get_parent().try_destroy_tile_at(body_rid, 4)

func turn_towards(to, delta):
	var theta = wrapf(atan2(to.y, to.x) - $head.rotation, -PI, PI)
	$head.rotation += clamp(delta, 0, abs(theta)) * sign(theta)

var player_valid = true
func forget_player():
	if chasing:
		chasing = false
		$head.sees_player = false
		cruising = true
		player_valid = false
func allow_target_player():
	player_valid = true