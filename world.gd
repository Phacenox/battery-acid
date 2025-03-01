extends Node2D

@export
var noise1 : FastNoiseLite
@export
var noise2 : FastNoiseLite
@export
var noise3 : FastNoiseLite
@onready
var layer0 : TileMapLayer = $Background
@onready
var layer1 : TileMapLayer = $TileMapLayer
@onready
var layer2 : TileMapLayer = $Overlay

var r_tile_coords = [Vector2i(0, 0), Vector2i(2, 0), Vector2i(0, 2)]
@export
var sparseness : float = 1.0

@export
var noise_ratio = 0.5

func sample_noise(pos: Vector2i) -> float:
	var ret =  noise1.get_noise_2d(pos.x * 20, pos.y * 20) * noise_ratio
	ret += noise2.get_noise_2d(pos.x * 20, pos.y * 20) * (1 - noise_ratio)
	return (ret + 1)

func clear():
	layer1.clear()
	layer2.clear()

enum exits { XPLUS, XMINUS, YPLUS, YMINUS }
# Called when the node enters the scene tree for the first time.
func build_chunk_at(start_position, chunk_size: int, this_seed, this_exits, destroy_data: Array[bool]):
	noise1.seed = this_seed
	noise2.seed = this_seed + 1
	noise3.seed = this_seed + 2
	for x in chunk_size:
		for y in chunk_size:
			var pos = Vector2i(x, y) + start_position
			var local_pos = Vector2i(x, y)
			if(should_be_scaffold(local_pos, this_exits)):
				layer0.set_cell(pos, 0, scaffold_type(local_pos))
			if(destroy_data[pos.y * 6 * chunk_size + pos.x]): continue
			if(should_be_solid_edge(local_pos, chunk_size, this_exits)):
				layer1.set_cell(pos, 0, Vector2i(2, 2))
				layer2.set_cell(pos, 0, Vector2i(1, 1))
			elif(sample_noise(pos) < distance_weight_from_center(local_pos, chunk_size, this_exits) / sparseness):
				var tile = floor((noise3.get_noise_2d(pos.x* 20, pos.y* 20) + 1) / 2 * 3) as int % 3
				layer1.set_cell(pos, 0, r_tile_coords[tile])
				layer2.set_cell(pos, 0, r_tile_coords[tile] / 2)

const edge_size = 2
func should_be_solid_edge(sample_position: Vector2i, chunk_size: int, this_exits):
	if(sample_position.x < edge_size || sample_position.x > chunk_size - edge_size - 1):
		if(sample_position.y < edge_size || sample_position.y > chunk_size - edge_size - 1):
			return true
	if(sample_position.x < edge_size && !this_exits.has(exits.XMINUS)):
		return true
	if(sample_position.x > chunk_size - edge_size - 1 && !this_exits.has(exits.XPLUS)):
		return true
	if(sample_position.y < edge_size && !this_exits.has(exits.YMINUS)):
		return true
	if(sample_position.y > chunk_size - edge_size - 1 && !this_exits.has(exits.YPLUS)):
		return true
	return false

func should_be_scaffold(sample_position: Vector2i, this_exits):
	if(sample_position.x < 5  && !this_exits.has(exits.XMINUS)):
		return false
	if(sample_position.x > 10  && !this_exits.has(exits.XPLUS)):
		return false
	if(sample_position.y < 5  && !this_exits.has(exits.YMINUS)):
		return false
	if(sample_position.y > 10  && !this_exits.has(exits.YPLUS)):
		return false

	if(sample_position.x == 6 || sample_position.x == 9):
		return true
	if(sample_position.y == 6 || sample_position.y == 9):
		return true
	return false

func scaffold_type(sample_position):
	if(sample_position.x == 6 || sample_position.x == 9):
		if(sample_position.y == 6 || sample_position.y == 9):
			return Vector2i(2, 0)
		return Vector2i(3, 1)
	return Vector2i(3, 0)

func distance_weight_from_center(sample_position: Vector2, chunk_size: int, this_exits) -> float:
	var r = ((sample_position + Vector2.ONE * 0.5) - (Vector2.ONE * chunk_size / 2)) / (chunk_size / 2.0)
	for item in this_exits:
		match item:
			exits.XPLUS:
				if(r.x > 0):
					r.x = min(r.x, abs(r.y))
			exits.XMINUS:
				if(r.x < 0):
					r.x = max(r.x, -abs(r.y))
			exits.YPLUS:
				if(r.y > 0):
					r.y = min(r.x, abs(r.y))
			exits.YMINUS:
				if(r.y < 0):
					r.y = max(r.x, -abs(r.y))
	return r.length()
@export var brokenwall: PackedScene
func break_tile(body: RID, strength: int):
	var coords = layer1.get_coords_for_body_rid(body)
	if(layer1.get_cell_atlas_coords(coords).length() <= strength):
		var b = brokenwall.instantiate()
		add_child(b)
		b.position = layer1.map_to_local(coords)
		b.atlas_coords = layer1.get_cell_atlas_coords(coords)
		b.break_block()
		layer1.set_cell(coords, 0)
		layer2.set_cell(coords, 0)
		return coords
	return false
