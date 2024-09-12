@tool
class_name MyRope
extends Node2D

# TODO: ropeSize is not an exact science, because of the constraint size
#		probably change the constraint size to work for the ropeSize on rope-set
#		...... I'm pretty sure changing the exports messes up while running too (callin eachother?)
# TODO: rope detache velocity acts weird because the attached extends the rope beyond its length
#		then the constraint back makes it act weird (I think)
# TODO: fix `segment_number` runtime adjustment unexpected physics (not too pressing unless I want to use that)

## emits the magnitude of stretch beyond `rope_length` or zero
signal rope_stretched(length: float)

@export_range(1, 9999999, 1, "or_greater") var rope_length:float = 200 :
	set(val):
		if val == rope_length or val < 1: return
		rope_length = val
		call_deferred("_resize_arrays")
		update_configuration_warnings()
@export_range(2, 9999999, 1, "or_greater") var segment_number: int = 10 : ## technically this is the point_number... (segments-1)
	set(val):
		## NOTE: setting during runtime will give unexpected physics results
		if val == segment_number or val < 1: return
		segment_number = val
		call_deferred("_resize_arrays")
		update_configuration_warnings()
@export var offset: Vector2 = Vector2.ZERO
@export var gravity := Vector2(0,20)
@export var tightness: int = 100 ## constraint iterations (a ratio more iterations will be applied if rope exceeds length)
@export_range(0.1, 1, .0001) var damping: float = .9
@export_range(0.1, .9999, .0001) var end_strength: float = .5
@export var color: Color = Color(0.648, 0.389, 0.056)
@export_range(1, 9999999, 1, "or_greater") var width: float = 2
@export var attached: Node2D = null :
	set(val):
		attached = val
		update_configuration_warnings()
		assert(_is_attached_processed_first())

var _line_2d := Line2D.new()

var _pos: PackedVector2Array
var _pos_prev: PackedVector2Array
var _translation: Vector2 :
	get:
		return global_position + offset
var _segment_length: float = rope_length / segment_number

var endpoint : Vector2 :
	get:
		return _pos[-1]
	set(val):
		_pos[-1] = val
## normalized direction vector of the end of the rope
var endDirection: Vector2 :
	get:
		return _pos[-2].direction_to(endpoint)
var start_direction: Vector2 :
	get:
		return _pos[0].direction_to(_pos[1])
var finalPosition: PackedVector2Array :
	get:
		# Get the parent's global transform (including rotation and scale)
		var parent_transform := (get_parent() as Node2D).global_transform
		
		# Create a transformation with translation and parent's rotation
		var transform := Transform2D().translated(_translation) * Transform2D().rotated(parent_transform.get_rotation())
		
		# Apply the transformation to the positions
		return _pos * transform
		
		#return _pos * Transform2D().translated(_translation)

func _get_configuration_warnings():
	var warnings = []
	
	if !(get_parent() is Node2D):
		warnings.append("parent must be Node2D")
	
	if _segment_length >= rope_length:
		warnings.append("`_segment_length` must be <= `rope_length`")
		
	if !_is_attached_processed_first():
		warnings.append("`attached` Node2d must be before rope in tree (such that it is processed first)")
	
	return warnings

func _ready() -> void:
	_line_2d.default_color = color
	_line_2d.width = width
	#_line_2d.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(_line_2d, false, InternalMode.INTERNAL_MODE_FRONT)
	_resize_arrays()
	
	call_deferred("_init_position")

func _process(_delta: float) -> void:
	assert(_is_attached_processed_first())
	_fix_children_to_endpoint()
	#queue_redraw()
	_line_2d.points = finalPosition

func _physics_process(delta: float) -> void:
	# set start of rope
	self.position = Vector2.ZERO # THIS WOKRS... but why does local pos change when new parent??
	self.rotation = (get_parent() as Node2D).rotation
	_pos[0] = global_position
	_pos_prev[0] = global_position
	
	_verlet_integrate_points(delta)
	
	# allow attached to affect rope before constraints
	if attached:
		endpoint = attached.global_position + offset
	
	_constrain()
	 
	# visually reattach endpoint to node
	#if attached: #TODO: I think constrain check may make this redundant
		#endpoint = attached.global_position + offset
	
	var actual_length := _pos[0].distance_to(endpoint)
	rope_stretched.emit(maxf(actual_length - rope_length, 0), start_direction, endDirection)

func _notification(what):
	match what:
		NOTIFICATION_PARENTED:
			assert(get_parent() is Node2D)

func apply_endpoint_impulse(velocity: Vector2) -> void:
	#_pos_prev[-1] = endpoint - (velocity * damping)
	_pos_prev[-1] = _pos_prev[-1] - (velocity * damping)

func _init_position() -> void:
	## the rope will be start in the avg direction of gravity and to where attached
	## actual length will never exceed beyond attached
	position = Vector2.ZERO
	var dir := (gravity + Vector2.ZERO if not attached else global_position.direction_to(attached.global_position)).normalized() 
	var dist_between := _segment_length if not attached else minf(_segment_length, attached.global_position.distance_to(global_position) / segment_number)
	for i in range(segment_number):
		var pos := offset + global_position + (dir * dist_between * i)
		_pos[i] = pos
		_pos_prev[i] = pos
	if attached:
		endpoint = attached.global_position + offset
	_fix_children_to_endpoint()

func _apply_impulse(velocity: Vector2, point: int) -> void:
	_pos_prev[point] = _pos_prev[point] - (velocity)

func _resize_arrays() -> void:
	## called by `segment_number` and `rope_length` setters and `_ready`
	_segment_length = rope_length / segment_number
	_pos.resize(segment_number)
	_pos_prev.resize(segment_number)

func _fix_children_to_endpoint() -> void:
	for c in get_children(false):
		if c is Node2D:
			c.global_position = endpoint #- _translation

func _verlet_integrate_points(delta: float) -> void:
	for i in range(1, len(_pos)):
		var velocity := (_pos[i] - _pos_prev[i]) * damping
		_pos_prev[i] = _pos[i]
		_pos[i] += velocity + (gravity * delta)

func _constrain() -> void:
	for _x in tightness:
		var is_constrained := true
		for i in range(len(_pos) - 1):
			var cur_dist := _pos[i].distance_to(_pos[i + 1])
			var error := _segment_length - cur_dist
			if error >= 0:
				continue
			is_constrained = false
			
			var percent := error / cur_dist
			var vec2 := _pos[i + 1] - _pos[i]
			
			if i == 0:
				# don't adjust first point (keep on parent)
				_pos[i+1] += vec2 * percent
			elif i + 1 == segment_number - 1:
				# last constraint (connected to endpoint)
				if attached:
					_pos[i] -= vec2 * percent
				else:
					_pos[i] -= vec2 * (percent * end_strength)
					_pos[i + 1] += vec2 * (percent * (1 - end_strength))
			else:
				# all points except start and end
				_pos[i] -= vec2 * (percent / 2)
				_pos[i + 1] += vec2 * (percent / 2)
		if is_constrained:
			# gone through an entire contraint loop without changing anything
			#print("loops saved: ", tightness - _x)
			break

func _is_attached_processed_first()-> bool:
	## return true if the attached node will run its _process and _physics_process methods prior to self
	var no_attached := (not attached) or (not attached.is_inside_tree())
	var in_tree := is_inside_tree()
	return no_attached or in_tree or is_greater_than(attached)

#func _draw() -> void:
	#var rope := finalPosition
	#for p in rope:
		#draw_circle(p, width/1.5, "pink")
