extends Node2D
@onready
var world = $Zone

const chunk_size = 16
var destroy_data: Array[bool]

@export
var enemy: PackedScene
@export
var enemy_chance: float = 0.3

func layer():
	return world.layer1
func explored_data():
	return get_parent().explored_data
func explore_tile(tile: Vector2i):
	if !get_parent().explored_data.has(tile):
		get_parent().explored_data.append(tile)

var this_seed
var map
var orbs: Array[Vector2i]
enum exits { XPLUS, XMINUS, YPLUS, YMINUS }
func build_level(orbs_count, orbs_collected, saved_seed):
	if fixed:
		return
	world.clear()
	var rng = RandomNumberGenerator.new()
	this_seed = saved_seed
	rng.seed = saved_seed

	map = [
		[[],[],[]],
		[[],[],[]],
		[[],[],[]],
		[[],[],[]],
		[[],[],[]],
		[[],[],[]]
		]
	const dangerous_exit_chance = 0.0
	for x in 6:
		#l/r exits
		if x == 0:
			for y in 3:
				if rng.randf() < dangerous_exit_chance:
					map[x][y].append(exits.XMINUS)
		if x == 5:
			for y in 3:
				if rng.randf() < dangerous_exit_chance:
					map[x][y].append(exits.XPLUS)
		#u/d exits
		if x == 1 || rng.randf() < dangerous_exit_chance:
			map[x][0].append(exits.YMINUS)
		if x == 4 || rng.randf() < dangerous_exit_chance:
			map[x][2].append(exits.YPLUS)
		#middle connections
		if x != 5:
			#random horizontal
			var xbridge1 = rng.randi_range(0, 2)
			var xbridge2 = rng.randi_range(0, 2)
			for y in 3:
				if !(y == xbridge1 || y == xbridge2):
					map[x][y].append(exits.XPLUS)
					map[x+1][y].append(exits.XMINUS)
		#always vertical
		for y in 2:
				map[x][y].append(exits.YPLUS)
				map[x][y+1].append(exits.YMINUS)

	for x in 6:
		for y in 3:
			var pos = Vector2i(x, y)
			build_chunk(pos, map[x][y])
	if enemy:
		for x in 6:
			for y in 3:
				if(rng.randf() <= enemy_chance):
					#print("spawned enemy at" + str((chunk_position as Vector2) + Vector2.ONE * 6))
					var e = enemy.instantiate()
					$creatures.add_child(e)
					e.global_position = global_position + Vector2(x, y) * chunk_size * 16 + Vector2.ONE * 8 * 16
	orbs = make_orbs(orbs_count, orbs_collected, rng)
	var to_spawn = orbs.duplicate()
	while len(to_spawn) > 0:
		await get_tree().process_frame
		var i = 0
		while i < len(to_spawn):
			var pos = Vector2i(rng.randi_range(0, 15), rng.randi_range(0, 15))
			var cell_pos = to_spawn[i] * 16 + pos
			if layer().get_cell_source_id(cell_pos) == -1:
				var new_cell_global_position = layer().to_global(layer().map_to_local(cell_pos))
				var orb = orb_packed.instantiate()
				add_child(orb)
				orb.global_position = new_cell_global_position
				orb.rest_area = get_parent().next_rest_area
				orb.where = to_spawn[i]
				orb.picked_up.connect(_on_orb_consumed)
				to_spawn.remove_at(i)
				i -= 1
			i += 1
func _on_orb_consumed(where):
	if orbs.find(where) >= 0:
		orbs.remove_at(orbs.find(where))
	get_tree().get_first_node_in_group("Game").render_minimap(true)
	get_parent().orbs_data.append(where)
@export
var orb_packed: PackedScene

func make_orbs(orbs_count, orbs_collected, rng):
	var ret: Array[Vector2i] = []
	for x in 6:
		for y in 3:
			ret.append(Vector2i(x, y))
	while len(ret) > orbs_count:
		ret.remove_at(rng.randi_range(0, len(ret) - 1))
	for i in orbs_collected:
		var has = ret.find(i)
		if has >= 0:
			ret.remove_at(has)
	return ret

func try_destroy_tile_at(body: RID, strength: int) -> bool:
	var result = world.break_tile(body, strength)
	if result is Vector2i && !fixed:
		destroy_data[result.y * 6 * chunk_size + result.x] = true
		return true
	return false

func build_chunk(chunk_position: Vector2i, this_exits: Array):
	world.build_chunk_at(chunk_position * chunk_size, chunk_size, this_seed, this_exits, destroy_data)

@export
var fixed: bool