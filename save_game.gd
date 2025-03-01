extends Node

@export
var ui_popup: AnimationPlayer
@export
var rest_areas: Array[Node2D]
@export
var levels: Array[Node2D]
@export
var tutorial_orbs: Array[Node2D]
func load():
	if not FileAccess.file_exists("user://savegame.save"):
		return
	var save_data = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json_string = save_data.get_line()
	var json = JSON.new()

	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	var data = json.data
	#if save game exists, delete orbs in level0
	for i in tutorial_orbs:
		i.queue_free()
	get_parent().player.global_position = str_to_var("Vector2" + data["player_position"])
	if data:
		levels[0].load(data["level1"])
		levels[1].load(data["level2"])
		levels[2].load(data["level3"])
		rest_areas[0].load(data["rest1"])
		rest_areas[1].load(data["rest2"])
		rest_areas[2].load(data["rest3"])
		rest_areas[3].load(data["rest4"])
	save_data.close()

func save(player_position):
	var data_store = {
		"player_position": player_position
	}
	data_store["level1"] = levels[0].save()
	data_store["level2"] = levels[1].save()
	data_store["level3"] = levels[2].save()
	data_store["rest1"] = rest_areas[0].save()
	data_store["rest2"] = rest_areas[1].save()
	data_store["rest3"] = rest_areas[2].save()
	data_store["rest4"] = rest_areas[3].save()
	
	var save_data = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_data.store_line(JSON.stringify(data_store))
	save_data.close()
	ui_popup.play("Save!")
