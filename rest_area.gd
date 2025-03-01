extends Node2D

@onready var layer1 = $Map/TileMapLayer
@onready var layer2 = $Map/Overlay
@export var brokenwall: PackedScene

var ending_sequence = false

func try_destroy_tile_at(body: RID, strength: int) -> bool:
	var coords = layer1.get_coords_for_body_rid(body)
	if(layer1.get_cell_atlas_coords(coords).length() <= strength):
		var b = brokenwall.instantiate()
		add_child(b)
		b.position = layer1.map_to_local(coords)
		b.atlas_coords = layer1.get_cell_atlas_coords(coords)
		b.break_block()
		layer1.set_cell(coords, 0)
		layer2.set_cell(coords, 0)
		return true
	return false

@export var levelloader_prev: Node2D
@export var levelloader_next: Node2D

@export
var prev_orbs_count: int
@export
var next_rest_area: Node2D

func load_next(_body):
	if orb_count >= len(orb_sockets):
		$Gate.open()
	if next_rest_area == null:
		get_tree().get_first_node_in_group("ui").show_battery_ui()
		get_tree().get_first_node_in_group("ui").set_orb_max(0)
		get_tree().get_first_node_in_group("ui").set_orb_count(0)
	else:
		get_tree().get_first_node_in_group("ui").set_orb_max(next_rest_area.prev_orbs_count)
		get_tree().get_first_node_in_group("ui").set_orb_count(next_rest_area.orb_count)

	if levelloader_prev != null:
		levelloader_prev.unloadlevel()
	if levelloader_next != null:
		levelloader_next.loadlevel()
	if(ending_sequence):
		call_deferred("kill_enemies")
	else:
		get_tree().get_first_node_in_group("SaveGame").save($Area2D2.global_position)

func kill_enemies():
		for i in get_tree().get_nodes_in_group("enemy"):
			i.queue_free()

func load_prev(_body):
	if orb_count >= len(orb_sockets):
		$Gate.open()
	if(ending_sequence):
		get_tree().get_first_node_in_group("ui").add_orbs(orb_count)
	else:
		get_tree().get_first_node_in_group("ui").set_orb_max(prev_orbs_count)
		get_tree().get_first_node_in_group("ui").set_orb_count(orb_count)
	if levelloader_next != null:
		levelloader_next.unloadlevel()
	if levelloader_prev != null:
		levelloader_prev.loadlevel()
	if(ending_sequence):
		call_deferred("kill_enemies")
	else:
		get_tree().get_first_node_in_group("SaveGame").save($Area2D.global_position)

@export
var orb_sockets: Array[Sprite2D]
@export
var orb_socket_filled_texture: Texture

var orb_count = 0

func set_orb_count(amt: int):
	orb_count = amt
	for i in len(orb_sockets):
		if i < amt:
			orb_sockets[i].texture = orb_socket_filled_texture

func add_orb():
	set_orb_count(orb_count + 1)

func add_orbs(amt):
	set_orb_count(orb_count + amt)

func save():
	return {
		"count": orb_count
	}

func load(data):
	set_orb_count(data.count)