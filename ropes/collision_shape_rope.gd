#@tool
class_name CollisionShapeRope
extends MyRope

func _move_segments_within_collisions_object(collision_obj: CollisionObject2D) -> void:
	## Segments are represented by RectangleShape2D
	var points := self.finalPosition
	var p_count: int = len(points)
	var seg_count: int = collision_obj.get_child_count()
	
	# add segments
	while seg_count < p_count - 1:
		seg_count +=1
		var new_shape := CollisionShape2D.new()
		#var segment := SegmentShape2D.new()
		var segment := RectangleShape2D.new()
		new_shape.shape = segment
		collision_obj.add_child(new_shape)
	
	# remove segments
	while seg_count > p_count - 1:
		collision_obj.get_child(seg_count-1).queue_free()
		seg_count -=1
	
	assert(seg_count == p_count-1)
	# move segments
	for i in p_count - 1:
		#var segment: = collision_obj.get_child(i)
		#segment.shape.a = points[i]
		#segment.shape.b = points[i + 1]
		var segment := collision_obj.get_child(i) as CollisionShape2D
		var rect := segment.shape as RectangleShape2D
		
		# Calculate height (distance between points)
		var point_a: Vector2 = points[i]
		var point_b: Vector2 = points[i + 1]
		var height: float = point_a.distance_to(point_b)
		
		# Set rectangle properties
		rect.size = Vector2(height, width)  # width is a class member variable
		segment.position = (point_a + point_b) / 2
		
		# Set the rotation based on the direction of the segment
		var direction: Vector2 = (point_b - point_a).normalized()
		segment.rotation = direction.angle()
