@tool
class_name AreaRope
extends CollisionShapeRope

@export_flags_2d_physics var mask := 1 :
	set(val):
		mask = val
		if not area_2d: return
		area_2d.collision_mask = mask

@onready var area_2d: CollisionObject2D = %Area2dSegments

func _ready() -> void:
	super()
	area_2d.collision_mask = mask

func _process(delta: float) -> void:
	super(delta)
	_move_segments(area_2d)

func _is_child_affixed(c: Node)-> bool:
	# prevent area segments from being oriented at end of rope
	return super(c) and c != area_2d

func _on_body_entered(body: Node2D) -> void:
	print(body)
