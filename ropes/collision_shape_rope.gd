@tool
class_name CollisionShapeRope
extends Rope

func _move_segments(collision_obj: CollisionObject2D) -> void:
	var points := self.finalPosition
	var p_count: int = len(points)
	var seg_count: int = collision_obj.get_child_count()
	
	# add segments
	while seg_count < p_count - 1:
		var new_shape := CollisionShape2D.new()
		collision_obj.add_child(new_shape)
		var segment := SegmentShape2D.new()
		segment.a = points[seg_count]
		segment.b = points[seg_count + 1]
		new_shape.shape = segment
		seg_count +=1
	
	# remove segments
	while seg_count > p_count - 1:
		collision_obj.get_child(seg_count-1).queue_free()
		seg_count -=1
	
	assert(seg_count == p_count-1)
	# move segments
	for i in p_count - 1:
		var segment: = collision_obj.get_child(i)
		segment.shape.a = points[i]
		segment.shape.b = points[i + 1]
