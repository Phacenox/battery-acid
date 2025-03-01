extends Control

@export
var tile_packed: PackedScene
@export
var minimap_center: Sprite2D
@export
var tile_size = Vector2i(8, 8)

var minimap_data: Array[bool]

enum exits { XPLUS, XMINUS, YPLUS, YMINUS }
func rendermap(data: Array, explored: Array[Vector2i], orbs: Array[Vector2i], player_pos: Vector2i):
	for c in get_children():
		if c != minimap_center:
			c.queue_free()
	var tile_position
	var tile
	for pos in explored:
		tile_position = minimap_center.position + (-(player_pos - pos) * tile_size as Vector2);
		tile = tile_packed.instantiate()
		add_child(tile)
		tile.position = tile_position
		for exit in data[pos.x][pos.y]:
			tile = tile_packed.instantiate()
			add_child(tile)
			tile.position = tile_position
			match exit:
				exits.XPLUS:
					tile.frame = 2
				exits.YMINUS:
					tile.frame = 3
				exits.XMINUS:
					tile.frame = 4
				exits.YPLUS:
					tile.frame = 5
		if orbs.has(pos):
			tile = tile_packed.instantiate()
			add_child(tile)
			tile.position = tile_position
			tile.frame = 6
	
	if explored.is_empty():
		return
	#exits
	tile_position = minimap_center.position + (-(player_pos - Vector2i(1, -1)) * tile_size as Vector2);
	tile = tile_packed.instantiate()
	add_child(tile)
	tile.position = tile_position
	tile.frame = 8
	tile_position = minimap_center.position + (-(player_pos - Vector2i(4, 3)) * tile_size as Vector2);
	tile = tile_packed.instantiate()
	add_child(tile)
	tile.position = tile_position
	tile.frame = 8
