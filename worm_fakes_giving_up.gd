extends Area2D

@export
var worm: StaticBody2D


var triggered = false
func _on_body_entered(body:Node2D):
	if body.name == "Player" && !triggered:
		worm.giving_up = true
		triggered = true
