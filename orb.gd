extends Sprite2D

@export
var rest_area: Node2D

func _on_body_entered(body:Node2D):
	if body.name == "Player":
		get_tree().get_first_node_in_group("Player").get_node("ASM_collect").play()
		rest_area.add_orb()
		get_tree().get_first_node_in_group("ui").add_orb()
		picked_up.emit(where)
		queue_free()

var where: Vector2i
signal picked_up(where)