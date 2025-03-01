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
var worm : PhysicsBody2D
var emote: Curve = null
var timer = 0
var sees_player = false
@export
var player_damage = 100

var stopped = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stopped: return
	if sees_player:
		var player = get_tree().get_first_node_in_group("Player")
		set_jaw_angle(distance_to_player_curve.sample((player.global_position - global_position).length() / distance_to_player_scale))
		if worm.stunned <= 0 && (player.global_position - global_position).length() / distance_to_player_scale < 0.12:
			var ui = get_tree().get_first_node_in_group("ui")
			if(ui.damage + player_damage >= ui.canisters * 100):
				player.kill(true)
			else:
				worm.forward_v = -worm.cruising_speed * 2
				player.bump(transform.x)
			get_tree().get_first_node_in_group("Player").get_node("ASM_munch").play()

			worm.chasing = false
			sees_player = false
			ui.hurt(player_damage)
			worm.stunned = 5
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
