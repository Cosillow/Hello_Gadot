@tool
class_name AreaRope
extends CollisionShapeRope

@export_flags_2d_physics var mask := 1 :
	set(val):
		mask = val
		if not area_2d: return
		area_2d.collision_mask = mask

@onready var area_2d := Area2D.new()

func _ready() -> void:
	super()
	area_2d.collision_mask = mask
	area_2d.collision_layer = 0
	add_child(area_2d, false, InternalMode.INTERNAL_MODE_FRONT)
	_move_segments_within_collisions_object(area_2d)

func _physics_process(delta: float) -> void:
	super(delta)
	_move_segments_within_collisions_object(area_2d)

func _on_body_entered(body: Node2D) -> void:
	print(body)
