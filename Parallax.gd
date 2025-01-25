@tool
extends TextureRect

@export
var offset : Vector2

func _process(_delta):
    (material as ShaderMaterial).set_shader_parameter("offset", offset)