extends ColorRect

@export
var game_scene : PackedScene

func start_game(new_game = true):
	if new_game:
		DirAccess.remove_absolute("user://savegame.save")
	$Curtain.close()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(game_scene)


func _ready():
	$VBoxContainer2/VBoxContainer/ContinueGame.disabled = not FileAccess.file_exists("user://savegame.save")

func quit():
	$Curtain.close()
	await get_tree().create_timer(1).timeout
	get_tree().quit()