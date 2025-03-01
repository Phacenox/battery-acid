extends Node2D

var current_level
@onready
var player = $Player
@onready
var minimap = $CanvasLayer/UI/leftside/Minimap/MinimapContainer

@export
var energy_pickup: PackedScene

func _ready():
	$CanvasLayer.visible = true
	minimap.rendermap([], arnil, arnil, Vector2i.ZERO)
	$SaveGame.load()

const arnil: Array[Vector2i] = []
func _process(_delta):
	spawn_pickups()
	render_minimap()

var last_tile = -Vector2i.ONE
func render_minimap(force = false):
	if current_level == null:
		minimap.rendermap([], arnil, arnil, Vector2i.ZERO)
		return
	var player_tile = current_level.layer().to_local(player.global_position)
	if player_tile.x < 0 || player_tile.y < 0:
		return
	player_tile /= 16 * 16
	player_tile = Vector2i(player_tile)
	if player_tile.x >= 6 || player_tile.y >= 3:
		return
	if last_tile != player_tile || force:
		current_level.explore_tile(player_tile)
		last_tile = player_tile
		minimap.rendermap(current_level.map, current_level.explored_data(), current_level.orbs, player_tile)

func set_level(level):
	self.current_level = level
	self.pickups = []#all were parented to old level. don't rememeber them.

var player_last_cell = Vector2i.ZERO
@export
var spawn_range: int = 10
@export
var spawn_chance = 0.8
var pickups = []
func spawn_pickups():
	if current_level == null:
		return
	var layer = current_level.layer()
	var player_cell = layer.local_to_map(layer.to_local(player.global_position))
	if player_last_cell != player_cell:
		if player_cell.x != player_last_cell.x:
			var sign_x: int = sign(player_cell.x - player_last_cell.x)
			for i: int in spawn_range*2:
				if randf() < spawn_chance:
					var cell_pos = player_cell + sign_x * spawn_range * Vector2i.RIGHT + Vector2i.DOWN * (i - spawn_range)
					if cell_pos.x >= 0 && cell_pos.y >= 0:
						if cell_pos.x < 16 * 6 && cell_pos.y < 16*3:
							if layer.get_cell_source_id(cell_pos) == -1:
								var new_cell_global_position = layer.to_global(layer.map_to_local(cell_pos))
								new_cell_global_position += Vector2(randi_range(-6, 6), randi_range(-6, 6))
								spawn_pickup(new_cell_global_position)
		if player_cell.y != player_last_cell.y:
			var sign_y: int = sign(player_cell.y - player_last_cell.y)
			for i: int in spawn_range*2:
				if randf() < spawn_chance:
					var cell_pos = player_cell + sign_y * spawn_range * Vector2i.DOWN + Vector2i.RIGHT * (i - spawn_range)
					if cell_pos.x >= 0 && cell_pos.y >= 0:
						if cell_pos.x < 16 * 6 && cell_pos.y < 16*3:
							if layer.get_cell_source_id(cell_pos) == -1:
								var new_cell_global_position = layer.to_global(layer.map_to_local(cell_pos))
								new_cell_global_position += Vector2(randi_range(-6, 6), randi_range(-6, 6))
								spawn_pickup(new_cell_global_position)
		var i = 0
		while i < len(pickups):
			var c = pickups[i]
			if c == null || c.is_queued_for_deletion():
				pickups.remove_at(i)
				continue
			if abs(c.global_position.x - player.global_position.x) > (spawn_range + 1)*16 || abs(c.global_position.y - player.global_position.y) > (spawn_range + 1)*16 :
				pickups.remove_at(i)
				i -= 1
				c.queue_free()
			i += 1

	player_last_cell = player_cell

func spawn_pickup(where):
	var i  = energy_pickup.instantiate()
	current_level.add_child(i)
	i.global_position = where
	pickups.append(i)


var cardinals = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
#after a delay, try to spawn a new pickup in a random direction by one tile
func pickup_consumed_at(_where):
	pass
	"""
	var layer = current_level.layer()
	var cell_pos = layer.local_to_map(layer.to_local(where)) + cardinals.pick_random()
	if layer.get_cell_source_id(cell_pos) == -1:
		await get_tree().create_timer(3).timeout
		var new_cell_global_position = layer.to_global(layer.map_to_local(cell_pos))
		new_cell_global_position += Vector2(randi_range(-6, 6), randi_range(-6, 6))
		spawn_pickup(new_cell_global_position)
"""
