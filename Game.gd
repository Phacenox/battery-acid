extends Node2D

func _ready():
    $CanvasLayer.visible = true
    $CanvasLayer/Curtain.open()
    $CanvasLayer/Curtain.state_value = 2