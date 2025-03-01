extends Area2D

@export
var worm: StaticBody2D

var triggered = false

func _on_body_entered(body:Node2D):
	if body.name == "Player" && !triggered:
		worm.giving_up = true
		worm.scream_cooldown = 0
		get_tree().get_first_node_in_group("ui").passive_loss = 0
		get_tree().get_first_node_in_group("camera").screen_shake = 4
		get_tree().get_first_node_in_group("camera").shake_amount = .3
		triggered = true