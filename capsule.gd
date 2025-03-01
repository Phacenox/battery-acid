extends AnimatedSprite2D

func _on_body_entered(body:Node2D):
	if body.name == "Player":
		get_tree().get_first_node_in_group("ui").recharge(25)
		get_tree().get_first_node_in_group("Player").get_node("ASM_collect").play()
		get_tree().get_first_node_in_group("Game").pickup_consumed_at(global_position)
		queue_free()