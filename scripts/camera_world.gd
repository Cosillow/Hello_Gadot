extends Node2D

@onready var bordered_cam: Camera2D = %BorderedCam

@onready var world_boundry: StaticBody2D = %WorldBoundry

func _ready() -> void:
	var center := bordered_cam.get_screen_center_position()
	var camera_size := get_viewport_rect().size * bordered_cam.zoom
	var camera_rect := Rect2(center - camera_size / 2, camera_size)
	var x_from_center := camera_rect.size.x / 2
	var y_from_center := camera_rect.size.y / 2
	var positions := [Vector2.UP, -y_from_center, Vector2.DOWN, y_from_center, Vector2.LEFT, -x_from_center, Vector2.RIGHT, x_from_center]
	
	for i in 4:
		var shape := CollisionShape2D.new()
		var boundary := WorldBoundaryShape2D.new()
		boundary.normal = positions[i]
		boundary.distance = positions[i+1]
		shape.shape = boundary
		world_boundry.add_child(shape)
