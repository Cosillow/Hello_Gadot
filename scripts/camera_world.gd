extends Node2D

@onready var bordered_cam: Camera2D = %BorderedCam

@onready var world_boundry: StaticBody2D = %WorldBoundry

func _ready() -> void:
	var center := bordered_cam.get_screen_center_position()
	bordered_cam.custom_viewport
	
	var camera_size := get_viewport().get_visible_rect().size / bordered_cam.zoom
	var camera_rect := Rect2(center - camera_size / 2, camera_size)
	var x_from_center := -camera_rect.size.x / 2
	var y_from_center := -camera_rect.size.y / 2
	print(camera_size)
	var positions := [[Vector2.DOWN, y_from_center], [Vector2.UP, y_from_center], [Vector2.RIGHT, x_from_center], [Vector2.LEFT, x_from_center]]
	
	for i in range(len(positions)):
		var shape := CollisionShape2D.new()
		var boundary := WorldBoundaryShape2D.new()
		world_boundry.add_child(shape)
		boundary.normal = positions[i][0]
		#boundary.distance = positions[i][1]
		shape.position += boundary.normal * positions[i][1]
		shape.shape = boundary
