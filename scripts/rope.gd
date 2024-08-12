class_name Rope
extends Node2D

# TODO: CURRENTLY... the _parent_cache must be of Node2d... otherwise it crashes
#		idk what the behavior should be for that, probably just fall to gravity?
#		also... I have zero error checking if there is no _parent_cache
# TODO: boolean exports for the rope just affecting the _parent_cache/child velocity, not just setting position
# TODO: ropeSize is not an exact science, because of the constraint size
#		probably change the constraint size to work for the ropeSize on rope-set
# TODO: _notification doesn't work all the time for reparenting... I've found it is because
#		(in some way) the position of the rope is not always 0 when it swaps parents. Should I
#		be using global position some places instead?

@export var ropeLength:float = 30 :
	set(length):
		ropeLength = length
		call_deferred("_ready")
## constraint iterations (a ratio more iterations will be applied if rope exceeds length)
@export var tightness: int = 100 
## distance between points (must be < ropeLength)
@export_range(1, 9999999, 1, "or_greater") var constrain: float = 1 :
	set(val):
		constrain =  max(1, min(val, ropeLength - 0.1))
		call_deferred("_ready")
@export var gravityAdjustment: float = 0
@export_range(0.1, 0.9, .01) var dampening: float = 0.9
@export var endPin: bool = true
@export var color: Color = Color(0.648, 0.389, 0.056)
@export_range(1, 9999999, 1, "or_greater") var width: float = 2
@onready var prGravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")/50
var gravity: Vector2 :
	get:
		return Vector2(0, prGravity + gravityAdjustment)
var _point_count: int
var _pos: PackedVector2Array
var _pos_prev: PackedVector2Array

var finalPosition: PackedVector2Array :
	get:
		return _pos * Transform2D().translated(_parent_cache.position)
var _parent_cache: Node2D = null

func _ready()->void:
	_point_count = int(ceil(ropeLength / constrain))
	
	# resize arrays
	_pos.resize(_point_count)
	_pos_prev.resize(_point_count)
	
	# init position
	print(self.name, " init position: %v" % [position])
	position = Vector2.ZERO
	for i in range(_point_count):
		_pos[i] = position + Vector2(0, constrain *i)
		_pos_prev[i] = position + Vector2(0, constrain *i)

func _notification(what):
	match what:
		NOTIFICATION_PARENTED:
			var p = get_parent()
			if !(p is Node2D):
				_parent_cache = null
				return
				
			_parent_cache = p
			set_deferred("position", Vector2.ZERO)
			call_deferred("set_start", _parent_cache.position)
			print("PARENTED:: position: %v, parent pos: %v" % [position, _parent_cache.position])
		NOTIFICATION_UNPARENTED:
			print("UNPARENTED:: position: %v" % [position])
			_parent_cache = null

func _physics_process(delta)->void:
	if not _parent_cache: return
	_update_points(delta)
	
	# tighten rope more if it exceeds ropeLength
	var distSq = _pos[0].distance_squared_to(_pos[_point_count-1])
	var possibleError = distSq / pow(ropeLength,2)
	var iterations = max(tightness,int(possibleError * tightness))
	for i in iterations:
		_update_constrain()
	
	set_start(_parent_cache.position)
	for c in get_children():
		if c is Node2D:
			c.position = _pos[_point_count-1] - _parent_cache.position
	queue_redraw()

func set_start(p:Vector2)->void:
	_pos[0] = p
	_pos_prev[0] = p

func _update_points(delta)->void:
	for i in range (_point_count):
		# TODO: may need to adjust this if AFFECTING _parent_cache/child not just changing _pos
		if (i!=0) || (i==0 && !_parent_cache):
			var velocity = (_pos[i] -_pos_prev[i]) * dampening
			_pos_prev[i] = _pos[i]
			_pos[i] += velocity + (gravity * delta)

func _update_constrain()->void:
	for i in range(_point_count):
		if i == _point_count-1:
			return
		var distance = _pos[i].distance_to(_pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = _pos[i+1] - _pos[i]
		
		# if first point
		if i == 0:
			if _parent_cache:
				_pos[i+1] += vec2 * percent
			else:
				_pos[i] -= vec2 * (percent/2)
				_pos[i+1] += vec2 * (percent/2)
		# if last point, skip because no more points after it
		elif i == _point_count-1:
			pass
		# all the rest
		else:
			if i+1 == _point_count-1 && endPin:
				_pos[i] -= vec2 * percent
			else:
				_pos[i] -= vec2 * (percent/2)
				_pos[i+1] += vec2 * (percent/2)

func _draw() -> void:
	var rope := finalPosition
	draw_polyline(rope, color, float(width))
	for p in rope:
		draw_circle(p, width/1.5, "pink")
