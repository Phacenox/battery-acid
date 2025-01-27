extends Node2D

@export
var noise1 : FastNoiseLite
@export
var noise2 : FastNoiseLite
@export
var noise3 : FastNoiseLite

@onready
var layer1 : TileMapLayer = $TileMapLayer
@onready
var layer2 : TileMapLayer = $Overlay

var r_tile_coords = [Vector2i(0, 0), Vector2i(2, 0), Vector2i(0, 2)]
const chunk_size = 16
@export
var sparseness : float = 1.0

@export
var noise_ratio = 0.5

@export
var this_seed = 0

func sample_noise(pos: Vector2i) -> float:
	var ret =  noise1.get_noise_2d(pos.x * 20, pos.y * 20) * noise_ratio
	ret += noise2.get_noise_2d(pos.x * 20, pos.y * 20) * (1 - noise_ratio)
	return (ret + 1)


# Called when the node enters the scene tree for the first time.
var chunk_worldposition = Vector2i(0, 0)
func _ready():
	noise1.seed = this_seed
	noise2.seed = this_seed + 1
	noise3.seed = this_seed + 2
	var rng = RandomNumberGenerator.new()
	rng.seed = this_seed
	layer1.clear()
	layer2.clear()
	for x in chunk_size:
		for y in chunk_size:
			var pos = Vector2i(x, y)
			if(should_be_solid_edge(pos)):
				layer1.set_cell(pos, 0, Vector2i(2, 2))
				layer2.set_cell(pos, 0, Vector2i(1, 1))
			elif(sample_noise(pos) < distance_weight_from_center(pos) / sparseness):
				var tile = floor((noise3.get_noise_2d(pos.x* 20, pos.y* 20) + 1) / 2 * 3) as int % 3
				layer1.set_cell(pos, 0, r_tile_coords[tile])
				layer2.set_cell(pos, 0, r_tile_coords[tile] / 2)
	global_position = chunk_worldposition

enum exits { XPLUS, XMINUS, YPLUS, YMINUS }
var this_exits = [exits.YPLUS, exits.XMINUS, exits.YMINUS]

const edge_size = 2
func should_be_solid_edge(sample_position: Vector2i):
	if(sample_position.x < edge_size || sample_position.x > chunk_size - edge_size - 1):
		if(sample_position.y < edge_size || sample_position.y > chunk_size - edge_size - 1):
			return true
	if(sample_position.x < edge_size && !this_exits.has(exits.XMINUS)):
		return true
	if(sample_position.x > chunk_size - edge_size - 1 && !this_exits.has(exits.XPLUS)):
		return true
	if(sample_position.y < edge_size && !this_exits.has(exits.YMINUS)):
		return true
	if(sample_position.y < chunk_size - edge_size - 1 && !this_exits.has(exits.YPLUS)):
		return true
	return false

func distance_weight_from_center(sample_position: Vector2) -> float:
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