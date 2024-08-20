@tool
class_name Rope
extends Node2D

# TODO: ropeSize is not an exact science, because of the constraint size
#		probably change the constraint size to work for the ropeSize on rope-set
#		...... I'm pretty sure changing the exports messes up while running too (callin eachother?)
# TODO: rope detache velocity acts weird because the attached extends the rope beyond its length
#		then the constraint back makes it act weird (I think)
# TODO: fix `segment_number` runtime adjustment unexpected physics (not too pressing unless I want to use that)
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
@export_range(0.1, 0.9, .01) var dampening: float = 0.9
@export var color: Color = Color(0.648, 0.389, 0.056)
@export_range(1, 9999999, 1, "or_greater") var width: float = 2
@export var attached: Node2D = null :
	set(val):
		attached = val
		update_configuration_warnings()
		assert(_is_attached_processed_first())

var _pos: PackedVector2Array
var _pos_prev: PackedVector2Array
var _endpoint : Vector2 :
	get:
		return _pos[-1]
	set(val):
		_pos[-1] = val
var _translation: Vector2 :
	get:
		return global_position + offset
var _segment_length: float = rope_length / segment_number

var endDirection: Vector2 :
	get:
		return _pos[-2].direction_to(_endpoint)
var finalPosition: PackedVector2Array :
	get:
		return _pos * Transform2D().translated(_translation)

func _get_configuration_warnings():
	var warnings = []
	
	if !(get_parent() is Node2D):
		warnings.append("parent must be Node2D")
	
	if _segment_length >= rope_length:
		warnings.append("`_segment_length` must be <= `rope_length`")
		
	if !_is_attached_processed_first():
		warnings.append("`attached` Node2d must be before rope in tree (such that it is processed first)")
	
	return warnings

func _ready()->void:
	_resize_arrays()
	
	# init position
	position = Vector2.ZERO
	for i in range(segment_number):
		_pos[i] = global_position + Vector2(0, _segment_length *i)
		_pos_prev[i] = global_position + Vector2(0, _segment_length *i)
	_fix_children_to_endpoint()

func _physics_process(delta)->void:
	assert(_is_attached_processed_first())
	
	self.position = Vector2.ZERO # THIS WOKRS... but why does local pos change when new parent??
	set_start(global_position)
	_update_points(delta)
	
	# allow attached to affect rope before constraints
	if attached:
		_endpoint = attached.global_position
	
	# tighten rope more if it exceeds rope_length
	var distSq = _pos[0].distance_squared_to(_endpoint)
	var possibleError = distSq / pow(rope_length,2)
	var iterations = max(tightness,int(possibleError * tightness))
	for i in iterations:
		_update_constrain()
	
	# visually reattach endpoint to node
	if attached:
		_endpoint = attached.global_position
	
	_fix_children_to_endpoint()
	queue_redraw()

func _notification(what):
	match what:
		NOTIFICATION_PARENTED:
			assert(get_parent() is Node2D)

func set_start(p:Vector2) -> void:
	_pos[0] = p
	_pos_prev[0] = p

func set_endpoint_velocity(velocity: Vector2) -> void:
	_pos_prev[-1] = _endpoint - (velocity*dampening)

func _resize_arrays() -> void:
	## called by `segment_number` and `rope_length` setters and `_ready`
	_segment_length = rope_length / segment_number
	_pos.resize(segment_number)
	_pos_prev.resize(segment_number)

func _fix_children_to_endpoint() -> void:
	for c in get_children():
		if c is Node2D:
			c.position = _endpoint - _translation

func _update_points(delta)->void:
	for i in range(1, len(_pos)):
		var velocity = (_pos[i] -_pos_prev[i]) * dampening
		_pos_prev[i] = _pos[i]
		_pos[i] += velocity + (gravity * delta)

func _update_constrain()->void:
	for i in range(len(_pos)-1):
		var distance = _pos[i].distance_to(_pos[i+1])
		var difference = _segment_length - distance
		var percent = difference / distance
		var vec2 = _pos[i+1] - _pos[i]
		
		# if first point
		if i == 0:
			#if _parent_cache:
			_pos[i+1] += vec2 * percent
			#else:
				#_pos[i] -= vec2 * (percent/2)
				#_pos[i+1] += vec2 * (percent/2)
		else:
			#if i+1 == segment_number-1 && endPin:
				#_pos[i] -= vec2 * percent
			#else:
			_pos[i] -= vec2 * (percent/2)
			_pos[i+1] += vec2 * (percent/2)

func _is_attached_processed_first()-> bool:
	## return true if the attached node will run its _process and _physics_process methods prior to self
	if (not attached) or (not attached.is_inside_tree()): return true
	if not is_inside_tree(): return true
	return is_greater_than(attached)

func _draw() -> void:
	var rope := finalPosition
	draw_polyline(rope, color, float(width))
	#for p in rope:
		#draw_circle(p, width/1.5, "pink")
