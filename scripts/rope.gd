#@tool
class_name Rope
extends Node2D

# TODO: CURRENTLY... the _parent_cache must be of Node2d... otherwise it crashes
#		idk what the behavior should be for that, probably just fall to _gravity?
#		also... I have zero error checking if there is no _parent_cache
# TODO: boolean exports for the rope just affecting the _parent_cache/child velocity, not just setting position
# TODO: ropeSize is not an exact science, because of the constraint size
#		probably change the constraint size to work for the ropeSize on rope-set
# TODO: _notification doesn't work all the time for reparenting... I've found it is because
#		(in some way) the position of the rope is not always 0 when it swaps parents. Should I
#		be using global position some places instead?
# TODO: detatch from parent or detatch children? only if necessary for other objects

# IDEA: because the children update first, they will be displaced from the actual _endpoint of the rope
#		so, (only taking into account their x position probably {although, I'm considering the situation where the end 
#		of the rope has swung up and yPos would give a better feeling of weight}) we could average or use a `childrens affect`
#		ratio to determine where the new end point should be. My question is, when do I do this? I suspect it must
#		be before the constraints (which means after we would still have to set the children back to the end result)
#		possibly even we have to do this before the points are updated. I'm unsure
# TODO: this is close ^^ with _update_new_endpoint(), but it doesn't take into account the fact that the player is still being
#		affected by its physics update even after its position is set. defered set doesn't seem to work either (player is locked to _endpoint)

# IDEA: I can keep the parent child structure because that is helpful for quickly setting up static scenes with ropes
#		if I want a player to be attached, there needs to be an export variable for the player. I will keep the player in the top of all scenes,
#		ensuring its _physics_process() runs before all ropes, allowing the affected _endpoint to be calculated based on the characters already calculated position
# ** keep the game tree like this and all should be good? **
#┖╴root
   #┠╴Character (you are here!)
   #┃  ┠╴Sword
   #┃  ┖╴Backpack
   #┃     ┖╴Dagger
   #┠╴MyGame
   #┖╴Swamp
	  #┠╴Rope
	  #┠╴Rope
	  #┖╴Goblin
# TODO: assert/node warning setup thing that only allows rope parent to be Node2d
# TODO: remove previous parent cache error handling (now, I just assert parent is Node2d)

@export var ropeLength:float = 30 :
	set(val):
		if val == ropeLength:
			return
		ropeLength = val
		_point_count = int(ceil(ropeLength / constrain))
		call_deferred("_ready")
@export var tightness: int = 100 ## constraint iterations (a ratio more iterations will be applied if rope exceeds length)
@export_range(1, 9999999, 1, "or_greater") var constrain: float = 2 : ## distance between points (must be < ropeLength)
	set(val):
		if val == constrain:
			return
		constrain =  max(1, min(val, ropeLength - 0.1))
		_point_count = int(ceil(ropeLength / constrain))
		call_deferred("_ready")
@export var gravityAdjustment: float = 0 :
	set(val):
		gravityAdjustment = val
		_gravity = Vector2(0, prGravity + gravityAdjustment)
@export_range(0.1, 0.9, .01) var dampening: float = 0.9
@export var color: Color = Color(0.648, 0.389, 0.056)
@export_range(1, 9999999, 1, "or_greater") var width: float = 2
@export var attached: Node2D = null :
	set(val):
		attached = val
		print(attached)
		update_configuration_warnings()
		assert(_is_attached_processed_first())
@onready var prGravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")/50

var _point_count: int
var _pos: PackedVector2Array
var _pos_prev: PackedVector2Array
var _parent_cache: Node2D = null
var _gravity: Vector2
var _endpoint : Vector2 :
	get:
		return _pos[_point_count-1]
	set(val):
		_pos[_point_count-1] = val
var _translation: Vector2 :
	get:
		return _parent_cache.position if _parent_cache else Vector2.ZERO

var endDirection: Vector2 :
	get:
		return _pos[_point_count-2].direction_to(_endpoint)
var finalPosition: PackedVector2Array :
	get:
		return _pos * Transform2D().translated(_translation)

func _get_configuration_warnings():
	var warnings = []
	
	if !(get_parent() is Node2D):
		warnings.append("parent must be Node2D")
	
	if constrain >= ropeLength:
		warnings.append("`constrain` must be <= `ropeLength`")
		
	if !_is_attached_processed_first():
		warnings.append("`attached` Node2d must be before rope in tree (such that it is processed first)")
	# Returning an empty array means "no warning".
	return warnings

func _ready()->void:
	gravityAdjustment = gravityAdjustment # just so that the onready prGravity is added with setter
	#_point_count = int(ceil(ropeLength / constrain))
	
	# resize arrays
	_pos.resize(_point_count)
	_pos_prev.resize(_point_count)
	
	# init position
	position = Vector2.ZERO
	for i in range(_point_count):
		_pos[i] = global_position + Vector2(0, constrain *i)
		_pos_prev[i] = global_position + Vector2(0, constrain *i)
	_update_children()

func _physics_process(delta)->void:
	assert(_is_attached_processed_first())
	
	self.position = Vector2.ZERO # THIS WOKRS... but why does local pos change when new parent??
	set_start(_parent_cache.position)
	_update_points(delta)
	
	# allow attached to affect rope before constraints
	if attached:
		_endpoint = attached.global_position
	
	# tighten rope more if it exceeds ropeLength
	var distSq = _pos[0].distance_squared_to(_endpoint)
	var possibleError = distSq / pow(ropeLength,2)
	var iterations = max(tightness,int(possibleError * tightness))
	for i in iterations:
		_update_constrain()
	
	# visually reattach endpoint to node
	if attached:
		_endpoint = attached.global_position
	
	_update_children()
	queue_redraw()

func _notification(what):
	match what:
		NOTIFICATION_PARENTED:
			_parent_cache = get_parent()
			assert(_parent_cache is Node2D)
		NOTIFICATION_UNPARENTED:
			_parent_cache = null

func set_start(p:Vector2) -> void:
	_pos[0] = p
	_pos_prev[0] = p

func _update_children() -> void:
	for c in get_children():
		if c is Node2D:
			c.position = _endpoint - _translation

func _update_points(delta)->void:
	for i in range(1, _point_count):
		var velocity = (_pos[i] -_pos_prev[i]) * dampening
		_pos_prev[i] = _pos[i]
		_pos[i] += velocity + (_gravity * delta)

func _update_constrain()->void:
	for i in range(_point_count-1):
		var distance = _pos[i].distance_to(_pos[i+1])
		var difference = constrain - distance
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
			#if i+1 == _point_count-1 && endPin:
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
