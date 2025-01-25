@tool
extends ColorRect


@export
var state : bool :
    get : return _state
    set(value):
        if(value):
            state_value = min(state_value, 2)
        else:
            state_value = max(state_value, 0)
        _state = value

@export
var speed : float = 1

var _state : bool = false
var state_value = 0

func _process(delta):
    (material as ShaderMaterial).set_shader_parameter("value", state_value)
    if(state):
        state_value -= delta * speed
    else:
        state_value += delta * speed

func open():
    state = true;
func close():
    state = false;