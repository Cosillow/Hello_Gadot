class_name RopeConnection
extends Node

# TODO: push warnings for without a rope

@export var rope: MyRope = null
@export var start_body: RigidBody2D = null :
	set(val):
		start_body = val
		if val:
			_start_damp = val.linear_damp
@export var end_body: RigidBody2D = null :
	set(val):
		end_body = val
		if val:
			_end_damp = val.linear_damp

@export var stretch_lenience := 0
@export var tension_speed := 4000

@onready var pid_controller: PIDController = %PIDController

var _start_damp := 1.0
var _end_damp := 1.0

func _ready() -> void:
	rope.connect("rope_stretched", _on_stretch)
	if start_body:
		_start_damp = start_body.linear_damp
	if end_body:
		_end_damp = end_body.linear_damp

func _on_stretch(stretch_length: float, start_direction: Vector2, end_direction: Vector2, delta: float) -> void:
	if not start_body or not end_body:
		return
	stretch_length -= stretch_lenience
	if stretch_length <= 0:
		pid_controller.reset()
		return
		#start_body.linear_damp = _start_damp
		#end_body.linear_damp = _end_damp
		#return
	
	#var extra_damping := (stretch_length / rope.rope_length) * damping
	#start_body.linear_damp = _start_damp + extra_damping
	#end_body.linear_damp = _end_damp + extra_damping
	
	#var force := stretch_length * elasticity 
	var force := tension_speed * -pid_controller.update(stretch_length, 0, delta)
	#var dir := end_body.global_position.direction_to(start_body.global_position + rope.offset)
	start_body.apply_impulse(force * start_direction * delta, start_body.global_transform.basis_xform(rope.offset))
	end_body.apply_central_impulse(force * -end_direction * delta)
