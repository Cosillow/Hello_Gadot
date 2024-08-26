@tool
class_name AnimatableRope
extends CollisionShapeRope

@export_flags_2d_physics var layer := 1 :
	set(val):
		layer = val
		if not animatable_body: return
		animatable_body.collision_layer = layer

@onready var animatable_body: AnimatableBody2D = %AnimatableSegments

func _ready() -> void:
	super()
	animatable_body.collision_layer = layer

func _process(delta: float) -> void:
	super(delta)
	_move_segments(animatable_body)

func _is_child_affixed(c: Node)-> bool:
	# prevent area segments from being oriented at end of rope
	return super(c) and c != animatable_body
