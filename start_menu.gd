extends ColorRect

@export
var game_scene : PackedScene

func start_game():
	$Curtain.close()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(game_scene)
