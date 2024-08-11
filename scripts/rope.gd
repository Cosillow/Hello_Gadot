extends Node2D

@export var ropeLength:float = 30 :
	set(length):
		ropeLength = length
		call_deferred("init")
## constraint iterations (a ratio more iterations will be applied if rope exceeds length)
@export var tightness: int = 100 
## distance between points (must be < ropeLength)
@export_range(1, 9999999, 1, "or_greater") var constrain: float = 1 :
	set(val):
		constrain =  max(1, min(val, ropeLength - 0.1))
		call_deferred("init")
@export var gravityAdjustment: float = 0
@export_range(0.1, 0.9, .1) var dampening: float = 0.9
@export var endPin: bool = true
@export var color: Color = Color(0.648, 0.389, 0.056)
@export var attatchedTo: Node2D
@export var endAttatchment: Node2D
@export_range(1, 9999999, 1, "or_greater") var width: float = 2
@onready var prGravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")/50
var gravity: Vector2 :
	get:
		return Vector2(0, prGravity + gravityAdjustment)
var pointCount: int
var pos: PackedVector2Array
var posPrev: PackedVector2Array

func _ready()->void:
	# process_physics_priority is set to be after attatchedTo: Node2d
	# TODO: maybe... `attatchedTo` should just be the parent's position?
	init()

func init():
	pointCount = int(ceil(ropeLength / constrain))
	if attatchedTo:
		position = attatchedTo.position
	resize_arrays()
	init_position()

func resize_arrays():
	pos.resize(pointCount)
	posPrev.resize(pointCount)

func init_position()->void:
	for i in range(pointCount):
		pos[i] = position + Vector2(0, constrain *i)
		posPrev[i] = position + Vector2(0, constrain *i)
	position = Vector2.ZERO

#func _unhandled_input(event:InputEvent)->void:
	#if event is InputEventMouseMotion:
		#if Input.is_action_pressed("right_click"):	#Move start point
			#set_last(get_global_mouse_position())
	#elif event is InputEventMouseButton && event.is_pressed():
		#if event.button_index == 1:
			#set_start(get_global_mouse_position())
		#elif event.button_index == 2:
			#set_last(get_global_mouse_position())


func _physics_process(delta)->void:
	update_points(delta)
	
	# tighten rope more if it exceeds ropeLength
	var distSq = pos[0].distance_squared_to(pos[pointCount-1])
	var possibleError = distSq / pow(ropeLength,2)
	var iterations = max(tightness,int(possibleError * tightness))
	for i in iterations:
		update_constrain()
	
	if attatchedTo:
		#call_deferred("set_start", attatchedTo.position)
		set_start(attatchedTo.position)
	if endAttatchment:
		#call_deferred("attatch_last", endAttatchment)
		attatch_last(endAttatchment)
	for c in get_children():
		if c is Node2D:
			c.position = pos[pointCount-1]
	
	queue_redraw()
	
func set_start(p:Vector2)->void:
	pos[0] = p
	posPrev[0] = p

func attatch_last(n: Node2D)->void:
	n.position = pos[pointCount-1]

func update_points(delta)->void:
	for i in range (pointCount):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=pointCount-1) || (i==0 && !attatchedTo) || (i==pointCount-1 && !endPin):
			var velocity = (pos[i] -posPrev[i]) * dampening
			posPrev[i] = pos[i]
			pos[i] += velocity + (gravity * delta)

func update_constrain()->void:
	for i in range(pointCount):
		if i == pointCount-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		
		# if first point
		if i == 0:
			if attatchedTo:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		# if last point, skip because no more points after it
		elif i == pointCount-1:
			pass
		# all the rest
		else:
			if i+1 == pointCount-1 && endPin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)

func _draw() -> void:
	draw_polyline(pos, color, float(width))
	for p in pos:
		draw_circle(p, width/1.5, "pink")
