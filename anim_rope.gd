@tool
class_name AnimatableRope
extends CollisionShapeRope

@export var physics_material_override: PhysicsMaterial = null :
	set(val):
		physics_material_override = val
		if not animatable_body: return
		animatable_body.physics_material_override = physics_material_override
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

@onready var animatable_body := AnimatableBody2D.new()

func _ready() -> void:
	super()
	animatable_body.collision_layer = layer
	animatable_body.collision_mask = mask
	animatable_body.physics_material_override = physics_material_override
	animatable_body.sync_to_physics = false
	add_child(animatable_body, false, InternalMode.INTERNAL_MODE_FRONT)

func _physics_process(delta: float) -> void:
	super(delta)
	_move_segments(animatable_body)
	_handle_collisions()

func _handle_collisions() -> void:
	var space_state = get_world_2d().direct_space_state
	var point_i: int = -1
	for col_shape: CollisionShape2D in animatable_body.get_children().filter(func (c): return c is CollisionShape2D):
		point_i +=1
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = col_shape.shape
		query.collision_mask = animatable_body.collision_mask
		query.transform = col_shape.global_transform
		var contacts := space_state.collide_shape(query)
		var intersection := space_state.intersect_shape(query)
		
		for intersect_i in range(len(intersection)):
			# rare that this ever goes more than once, unless small segment number or lots of bodies
			#var collider: Node2D = collider_info.collider
			#var collider_position: = collider.global_position
			var collider_info := intersection[intersect_i]
			var collider: Node2D = collider_info.collider
			var collision_point := contacts[intersect_i*2] # first item in pair is shape
			
			var segment_start: Vector2 = col_shape.global_position + col_shape.shape.a
			var segment_end: Vector2 = col_shape.global_position + col_shape.shape.b
			var impulse_magnitude: float = 10
			var segment_velocity: Vector2= ( (_pos[point_i] - _pos_prev[point_i]) + (_pos[point_i+1] - _pos_prev[point_i+1]) ) / 2
			
			match typeof(collider):
				RigidBody2D:
					var b := collider as RigidBody2D
					var relative_velocity: Vector2 = b.linear_velocity - segment_velocity
					impulse_magnitude = relative_velocity.length() * b.mass
				
				CharacterBody2D:
					var b := collider as CharacterBody2D
					var relative_velocity: Vector2= b.velocity - segment_velocity
					impulse_magnitude = relative_velocity.length() * 0.5 # CharacterBody2D usually have lower mass
				
				StaticBody2D:
					var relative_velocity := -segment_velocity
					impulse_magnitude = relative_velocity.length() * 2 # Static bodies are immovable, so increase impulse


			var segment_length := segment_start.distance_to(segment_end)
			var ratio := segment_start.distance_to(collision_point) / segment_length
			ratio = clamp(ratio, 0.0, 1.0) # floating point errors will sometimes result in a ratio a bit above 1 (maybe below zero, I haven't seen that in testing)
			
			var force_direction = (contacts[1] - collision_point).normalized()
			#var force_direction2 = (col_shape.global_position - collider_position).normalized()
			#print("force_dir1: ", force_direction, " force_dir2: ", force_direction2, " col_pos: ", collider_position, " seg: ", {"a":col_shape.shape.a, "b":col_shape.shape.b})
			_apply_impulse(force_direction * impulse_magnitude * ratio , point_i)
			_apply_impulse(force_direction * impulse_magnitude * (1 - ratio) , point_i + 1)
			#apply_force_to_rope(force_direction)
