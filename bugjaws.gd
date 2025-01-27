extends Sprite2D

@export
var jaw_l: Node2D
@export
var jaw_r: Node2D

@export
var distance_to_player_curve: Curve
@export
var distance_to_player_scale = 40.0
@export
var emote_0: Curve
@export
var emote_1: Curve

@export
var worm : CharacterBody2D
var emote: Curve = null
var timer = 0
var sees_player = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if sees_player:
		var player = get_tree().get_first_node_in_group("Player")
		set_jaw_angle(distance_to_player_curve.sample((player.global_position - global_position).length() / distance_to_player_scale))
		if (player.global_position - global_position).length() / distance_to_player_scale < 0.12:
			player.kill(true)#TODO: only if at 0 energy
			worm.stunned = 5
			sees_player = false
			emote = emote_0
			timer = -1
		return
	if emote == null && randf() > 0.998:
		emote = emote_0 if randf() > 0.5 else emote_1
		timer = 0
	elif emote != null:
		timer += delta
		set_jaw_angle(emote.sample(timer))
		if(timer > 1):
			emote = null


func set_jaw_angle(angle):
	jaw_l.rotation_degrees = -angle
	jaw_r.rotation_degrees = angle
