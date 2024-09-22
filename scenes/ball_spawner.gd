extends Node2D

const BALLS = preload("res://scenes/balls.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("add_platform"):
		var balls := BALLS.instantiate()
		
		add_child(balls)
		balls.position = get_global_mouse_position()
	elif event.is_action_pressed("remove_platforms"):
		for child in get_children():
			child.queue_free()
