extends Node2D

@export
var angular_range: float = 1
@export
var linear_range: float = 1
@export
var duration: float = 1
@export
var atlas_coords: Vector2i

func fadeout(sprite: Sprite2D):
	var posend = sprite.position + Vector2(randf_range(-linear_range, linear_range), randf_range(-linear_range, linear_range))
	var rotend = randf_range(-angular_range, angular_range)
	create_tween().tween_property(sprite, "position", posend, duration)
	create_tween().tween_property(sprite, "modulate", Color.TRANSPARENT, duration)
	var tlast = create_tween()
	tlast.tween_property(sprite, "rotation", rotend, duration)
	tlast.tween_callback(Callable.create(self, "queue_free")).set_delay(duration)

func break_block():
	$ASM_break.play()
	($Sprite2D as Sprite2D).frame_coords = atlas_coords
	($Sprite2D2 as Sprite2D).frame_coords = atlas_coords + Vector2i(1, 0)
	($Sprite2D3 as Sprite2D).frame_coords = atlas_coords + Vector2i(0, 1)
	($Sprite2D4 as Sprite2D).frame_coords = atlas_coords + Vector2i(1, 1)
	fadeout($Sprite2D)
	fadeout($Sprite2D2)
	fadeout($Sprite2D3)
	fadeout($Sprite2D4)