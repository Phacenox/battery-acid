extends Area2D

@export
var worm: StaticBody2D

@export
var new_curve: Curve

var triggered = false
func _on_body_entered(body:Node2D):
	if body.name == "Player" && !triggered:
		worm.giving_up = false
		worm.max_speed_curve = new_curve
		worm.global_position = global_position + Vector2.DOWN * 300
		worm.get_node("big_head").rotation_degrees = -90
		get_tree().get_first_node_in_group("camera").screen_shake = 2
		worm.scream_cooldown = 0
		triggered = true
