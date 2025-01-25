extends CharacterBody2D

func _process(_delta):
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_dir * 60
    move_and_slide()
    $Camera2D/TextureRect.offset += velocity * 0.00015