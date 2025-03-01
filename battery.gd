extends AnimatedSprite2D

func _on_body_entered(body:Node2D):
	if body.name == "Player":
		get_tree().get_first_node_in_group("ui").collect_battery()
		var c = $batterylight
		remove_child(c)
		get_tree().get_first_node_in_group("Player").add_child(c)
		get_tree().get_first_node_in_group("Player").get_node("ASM_collect").play()
		c.position = Vector2.ZERO
		queue_free()