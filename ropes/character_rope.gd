@tool
class_name CharacterRope
extends CollisionShapeRope

@export var bounce: float = .5
@export var depth_bias_factor: float = 0.08  ## Arbitrary bias factor to help with deep penetrations
@export_range(1, 20, 1, "or_greater") var body_affect_factor: float = 1

@export_flags_2d_physics var layer := 1 :
	set(val):
		layer = val
		if not char_body: return
		char_body.collision_layer = layer
@export_flags_2d_physics var mask := 1 :
	set(val):
		mask = val
		if not char_body: return
		char_body.collision_mask = mask

@onready var char_body := InternalCharacterBody.new()
var _collisions := false
var _col_color := Color.RED

func _ready() -> void:
	super()
	char_body.collision_layer = layer
	char_body.collision_mask = mask
	char_body.connect("collision_occurred", _handle_collision)
	add_child(char_body, false, InternalMode.INTERNAL_MODE_FRONT)
	_move_segments_within_collisions_object(char_body)
	
func _process(delta: float) -> void:
	if _collisions:
		_line_2d.default_color = _col_color
		_collisions = false
	else:
		_line_2d.default_color = color
	super(delta)

func _physics_process(delta: float) -> void:
	super(delta)
	_move_segments_within_collisions_object(char_body)

func _handle_collision(collision: KinematicCollision2D, delta: float) -> void:
	_collisions = true
	# TODO: maybeeee not a big deal, but this may happen while also touching a body?? NOTE I only noticed this briefly with some breakpoints
	# TODO: theres still the problem of multiple collision_shape contacts... which I could actually just handle from here by checking for more intersections with the shapes
	# TODO: LOOK INTO get_depth()... might be something there
	# TODO: different masses on the collidin bodies is kinda fucky wucky (especially with larger boddy affect factor)
	# TODO: it works....... but it clips through at high speed (because its not being affected enough here?)
	#		usually when it has a higher angular velocity... do I have to predict something along these lines?
	#		or... just assure the rope is affected more at its higher speeds
	# TODO: consider removing TEST's..
	# TODO: do not resolve if velocities are separating along normal: 
				  #/ Calculate relative velocity in terms of the normal direction 
				  #float velAlongNormal = DotProduct( rv, normal )
				  #// Do not resolve if velocities are separating 
				  #if(velAlongNormal > 0)
					#return;
	# TODO: mask and layer handling
	var collision_shape: CollisionShape2D = collision.get_local_shape() # NOTE: returns an object...
	var seg_i := collision_shape.get_index()
	var segment_velocity: Vector2 = ( (_pos[seg_i] - _pos_prev[seg_i]) + (_pos[seg_i+1] - _pos_prev[seg_i+1]) ) / 2
	segment_velocity /= delta # NOTE: convert verlet implicit velocity to explicit (per second)
	var collider_velocity := collision.get_collider_velocity()
	var relative_velocity: Vector2 = collider_velocity - segment_velocity
	var normal := collision.get_normal()
	
	# TEST
	# NOTE... the website says to check if > 0: return (his was just from the other perspective of the collision)
	var velocity_along_normal: = relative_velocity.dot(normal)
	if velocity_along_normal < 0:
		return
	
	var collision_point = collision.get_position() # NOTE: this is actually the at the depth of the collision objects penetration
	var collider := collision.get_collider()
	var depth := collision.get_depth()
	var segment_start: Vector2 = _pos[seg_i]
	var segment_end: Vector2 = _pos[seg_i+1]
	var shape := collision_shape.shape
	
	if shape is SegmentShape2D:
		segment_start = collision_shape.global_position + shape.a
		segment_end = collision_shape.global_position + shape.b
	#elif shape is RectangleShape2D:
		##assert(0)
		#return
	
	var segment_length := segment_start.distance_to(segment_end)
	var contact_on_segment: Vector2 = Geometry2D.get_closest_point_to_segment(collision_point, segment_start, segment_end)
	var ratio := segment_start.distance_to(contact_on_segment) / segment_length
	ratio = clamp(ratio, 0.0, 1.0) # NOTE: floating point errors will sometimes result in a ratio a bit above 1 (maybe below zero, I haven't seen that in testing)
	
	if collider is RigidBody2D:
		var impulse_magnitude: float= relative_velocity.length() * collider.mass
		
		
		# TEST: Calculate depth-based penetration bias to help resolve deep collisions
		#var penetration_depth: float = collision_point.distance_to(contact_on_segment)
		impulse_magnitude += depth * depth_bias_factor
		
		
		
		
		# apply impulse to RigidBody2D
		# NOTE: technically... I should be taking the minimum of the restituion (bounce) coefficients
		collider.apply_central_impulse(bounce * (-normal * (impulse_magnitude ) ) )
		
		# apply impulse to both points controlling the segment, weighted based on where the collision occurs along the segment
		impulse_magnitude *= delta # NOTE: convert explicit back to verlet for rope
		# `_apply_impulse` only affects _pos_prev, so it affects next physics tic (good because buffering)
		_apply_impulse(normal * body_affect_factor *impulse_magnitude * ratio , seg_i)
		_apply_impulse(normal * body_affect_factor *impulse_magnitude * (1 - ratio) , seg_i + 1)
		
		# TEST: Apply positional correction to resolve penetration
		var correction_factor: float = 0.1  # Small factor to correct penetration
		var correction_vector: Vector2 = normal * depth * correction_factor
		_pos[seg_i] += correction_vector * ratio
		_pos[seg_i + 1] += correction_vector * (1 - ratio)
		

class InternalCharacterBody extends CharacterBody2D:
	signal collision_occurred(collision: KinematicCollision2D)
	
	func _ready() -> void:
		motion_mode = MotionMode.MOTION_MODE_FLOATING
		#max_slides = 0 # NOTE: does not work...
	
	func _physics_process(delta: float) -> void:
		# TODO: look for both mask and layer, then handle collisions accordingly
		# dynamically add and remove collision exceptions by keeping track of each collision ID
		# emit `collision_occurred` if any
		var collisions: PackedInt64Array = []
		while true:
			var col := move_and_collide(Vector2.ZERO, true) 
			if not col:
				break
			var ID := col.get_collider_id()
			assert(ID not in collisions)
			collisions.push_back(ID)
			var collider: Node = col.get_collider() # NOTE: returns an Object...
			add_collision_exception_with(collider) # NOTE: must pass in a node... 
			collision_occurred.emit(col, delta)
			
		for ID in collisions:
			remove_collision_exception_with(instance_from_id(ID))
