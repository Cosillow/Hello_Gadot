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
	_handle_collisions(delta)

func _handle_collisions(delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	var point_i: int = -1
	for col_shape: CollisionShape2D in animatable_body.get_children().filter(func (c): return c is CollisionShape2D):
		# check each segment for collision
		point_i +=1
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = col_shape.shape
		query.collision_mask = animatable_body.collision_mask
		query.transform = col_shape.global_transform
		var contacts := space_state.collide_shape(query)
		var intersection := space_state.intersect_shape(query)
		
		# handle each collision on this segment
		# rare that this ever goes more than once, unless small segment number or lots of bodies
		for intersect_i in range(len(intersection)):
			var collider_dict := intersection[intersect_i]
			var collider: Object = collider_dict.collider
			var collision_point := contacts[intersect_i*2] # first item in vector pairs is the shape contact
			var segment_velocity: Vector2 = ( (_pos[point_i] - _pos_prev[point_i]) + (_pos[point_i+1] - _pos_prev[point_i+1]) ) / 2
			segment_velocity /= delta # convert verlet implicit velocity to explicit (per second)
			
			var impulse_magnitude: float = 10
			if collider is RigidBody2D:
				var relative_velocity: Vector2 = collider.linear_velocity - segment_velocity
				impulse_magnitude = relative_velocity.length() * collider.mass * delta
			elif collider is CharacterBody2D:
				var relative_velocity: Vector2 = collider.velocity - segment_velocity
				impulse_magnitude = relative_velocity.length() * 0.5 # CharacterBody2D usually have lower mass
			elif collider is StaticBody2D:
				var relative_velocity := -segment_velocity
				impulse_magnitude = relative_velocity.length() * 2 # Static bodies are immovable, so increase impulse
			
			# apply impulse to both points controlling the segment, weighted based on where the collision occurs along the segment
			var segment_start: Vector2 = col_shape.global_position + col_shape.shape.a
			var segment_end: Vector2 = col_shape.global_position + col_shape.shape.b
			var segment_length := segment_start.distance_to(segment_end)
			var ratio := segment_start.distance_to(collision_point) / segment_length
			ratio = clamp(ratio, 0.0, 1.0) # floating point errors will sometimes result in a ratio a bit above 1 (maybe below zero, I haven't seen that in testing)
			var impulse_direction = (contacts[1] - collision_point).normalized()
			_apply_impulse(impulse_direction * impulse_magnitude * ratio , point_i)
			_apply_impulse(impulse_direction * impulse_magnitude * (1 - ratio) , point_i + 1)
