extends Control

@export_file
var scene_path
@export
var curtain: ColorRect
func restart():
	curtain.close()
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()

func quit():
	curtain.close()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(load(scene_path))
