class_name Platform
extends Node2D

var platform = preload("res://scenes/platform.tscn")


func _input(event):
	if event.is_action_pressed("remove_platforms"):
		var platforms = get_children()
		print("removed "+ str(len(platforms)) + " platforms")
		for c in platforms:
			c.queue_free()

func _process(_delta):
	if Input.is_action_pressed("add_platform"):
		var p := platform.instantiate()
		add_child(p)
		p.position = get_global_mouse_position()
