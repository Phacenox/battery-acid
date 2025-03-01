extends Node2D

@export
var level: PackedScene
@export
var orbs_count = 3
@export
var saved_seed: int

var destroy_data: Array[bool]
var orbs_data: Array[Vector2i]
var explored_data: Array[Vector2i]
func _ready():
	destroy_data.resize(6*3*16*16)
	destroy_data.fill(false)
	orbs_data = []

func save():
	return {
		"seed": self.saved_seed,
		"destroy_data": self.destroy_data,
		"orbs_data": self.orbs_data,
		"explored_data": self.explored_data
	}
func load(dict):
	saved_seed = dict["seed"]
	var bool_array: Array[bool] = []
	bool_array.append_array(dict["destroy_data"])
	destroy_data = bool_array
	var vec2i_array: Array[Vector2i] = []
	for i in dict["orbs_data"]:
		vec2i_array.append(str_to_var("Vector2i" + i))
	orbs_data = vec2i_array
	vec2i_array = []
	for i in dict["explored_data"]:
		vec2i_array.append(str_to_var("Vector2i" + i))
	orbs_data = vec2i_array
	explored_data = vec2i_array

var l
func loadlevel():
	if l != null:
		return
	l = level.instantiate()
	l.destroy_data = destroy_data
	add_child(l)
	l.call_deferred("build_level", orbs_count, orbs_data, saved_seed)
	get_tree().get_first_node_in_group("Game").set_level(l)

func unloadlevel():
	if l == null:
		return
	destroy_data = l.destroy_data
	l.queue_free()
	l = null

@export
var next_rest_area: Node2D
