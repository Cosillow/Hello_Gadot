extends Node2D

@export var camera: Camera2D = null

var _curr_zoom: Vector2

func _ready() -> void:
	assert(camera)
	_curr_zoom = camera.zoom
	_move_boundaries(true)
	
func _process(_delta: float) -> void:
	if _curr_zoom != camera.zoom:
		_curr_zoom = camera.zoom
		_move_boundaries()
	
func _move_boundaries(is_init := false) -> void:
	var center := camera.get_screen_center_position()
	camera.custom_viewport
	
	var camera_size := get_viewport().get_visible_rect().size / camera.zoom
	var camera_rect := Rect2(center - camera_size / 2, camera_size)
	var x_from_center := -camera_rect.size.x / 2
	var y_from_center := -camera_rect.size.y / 2
	var positions := [[Vector2.DOWN, y_from_center], [Vector2.UP, y_from_center], [Vector2.RIGHT, x_from_center], [Vector2.LEFT, x_from_center]]
	
	for i in range(len(positions)):
		# TODO: only add on init...
		var shape: CollisionShape2D
		var boundary: WorldBoundaryShape2D
		if is_init:
			shape = CollisionShape2D.new()
			boundary = WorldBoundaryShape2D.new() 
			add_child(shape, false, Node.INTERNAL_MODE_FRONT)
			shape.shape = boundary
		else:
			shape = get_child(i, true) as CollisionShape2D
			boundary = shape.shape as WorldBoundaryShape2D
		boundary.normal = positions[i][0] as Vector2
		shape.position = boundary.normal * positions[i][1] as Vector2
