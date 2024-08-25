#@tool
extends Rope
class_name DetectionRope

@export_flags_2d_physics var mask = 1

@onready var area_2d: Area2D = %Area2DLine

func _ready():
	super()
	area_2d.collision_mask = mask

func _process(delta: float) -> void:
	super(delta)
	for c in area_2d.get_children():
		c.queue_free()
	var points = self.finalPosition
	for i in points.size() - 1:
		var new_shape := CollisionShape2D.new()
		area_2d.add_child(new_shape)
		var segment := SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape.shape = segment

func _is_child_affixed(c: Node)-> bool:
	# prevent area segments from being oriented at end of rope
	return super(c) and c != area_2d

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
