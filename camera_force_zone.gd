extends Area2D

@export
var lights: Array[PointLight2D]

var inside: bool = false
var ui

func _ready():
		for i in lights:
			i.enabled = false
		for i in get_parent().orb_sockets:
			i.visible = false

func _process(delta):
	if inside && !get_parent().ending_sequence:
		ui.heal(delta* 9 * ui.canisters)
		ui.recharge(delta * 12 * ui.canisters)

func _on_body_entered(body:Node2D):
	if body.name == "Player":
		for i in lights:
			i.enabled = true
		for i in get_parent().orb_sockets:
			i.visible = true
		inside = true
		ui = get_tree().get_first_node_in_group("ui")
		var camera = body.get_node("Camera2D")
		body.remove_child(camera)
		add_child(camera)
		camera.position = Vector2.ZERO
		for e in get_tree().get_nodes_in_group("enemy"):
			e.forget_player()


func _on_body_exited(body:Node2D):
	if body.name == "Player":
		for i in lights:
			i.enabled = false
		for i in get_parent().orb_sockets:
			i.visible = false
		inside = false
		var camera = get_node("Camera2D")
		remove_child(camera)
		body.add_child(camera)
		camera.position = Vector2.ZERO
		for e in get_tree().get_nodes_in_group("enemy"):
			e.allow_target_player()
