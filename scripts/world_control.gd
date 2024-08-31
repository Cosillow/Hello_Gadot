extends Node2D

@onready var ball_spawner: Node2D = %BallSpawner
const BALLS = preload("res://scenes/balls.tscn")
@onready var menu: Menu = %Menu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("add_platform"):
		var balls := BALLS.instantiate()
		
		ball_spawner.add_child(balls)
		balls.position = get_global_mouse_position()
	elif event.is_action_pressed("remove_platforms"):
		for child in ball_spawner.get_children():
			child.queue_free()
	elif event.is_action_pressed("menu"):
		menu.animate_view()

func _process(delta: float) -> void:
	pass
