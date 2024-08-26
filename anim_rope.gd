@tool
class_name AnimatableRope
extends CollisionShapeRope

@export_flags_2d_physics var layer := 1 :
	set(val):
		layer = val
		if not animatable_body: return
		animatable_body.collision_layer = layer

@export_flags_2d_physics var mask := 1 :
	set(val):
		mask = val
		if not animatable_body: return
		animatable_body.collision_mask = mask

@onready var animatable_body: AnimatableBody2D = %AnimatableSegments

func _ready() -> void:
	super()
	animatable_body.collision_layer = layer
	animatable_body.collision_mask = mask

func _physics_process(delta: float) -> void:
	super(delta)
	_move_segments(animatable_body)
	var space_state = get_world_2d().direct_space_state
	var point: int = -1
	for col_shape: CollisionShape2D in animatable_body.get_children().filter(func (c): return c is CollisionShape2D):
		point +=1
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = col_shape.shape
		query.collision_mask = animatable_body.collision_mask
		query.transform = col_shape.global_transform
		var intersection := space_state.intersect_shape(query)
		if intersection: 
			var collider_info := intersection[0]
			var collider: Node2D = collider_info.collider
			var collider_position: = collider.global_position
			
			var contacts := space_state.collide_shape(query)
			var force_direction = -(contacts[0] - contacts[1]).normalized()
			#var force_direction2 = (col_shape.global_position - collider_position).normalized()
			#print("force_dir1: ", force_direction, " force_dir2: ", force_direction2, " col_pos: ", collider_position, " seg: ", {"a":col_shape.shape.a, "b":col_shape.shape.b})
			_apply_impulse(force_direction*20, point)
			#apply_force_to_rope(force_direction)

func _is_child_affixed(c: Node)-> bool:
	# prevent area segments from being oriented at end of rope
	return super(c) and c != animatable_body
