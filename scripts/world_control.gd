extends Node2D

@onready var menu: Menu = %Menu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		menu.animate_view()
