extends Area2D

var triggered = false
func _on_body_entered(body:Node2D):
	if body.name == "Player" && !triggered:
		var c = body.get_node("Camera2D")
		body.remove_child(c)
		add_child(c)
		body.force_up = true
		triggered = true
		var game = get_tree().get_first_node_in_group('Game')
		game.get_node("CanvasLayer/GameOver").visible = true
		game.get_node("CanvasLayer/GameOver/Label").text = "POWER SOURCE RECOVERED"
		game.get_node("CanvasLayer/GameOver/Label2").visible = true
		var t1 = create_tween()
		t1.tween_property(game.get_node("CanvasLayer/GameOver"), "modulate", Color.WHITE, 2).set_delay(5)