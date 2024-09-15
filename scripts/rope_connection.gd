class_name RopeConnection
extends Node

## necessary children
@export var rope: MyRope
@export var start_body: RigidBody2D
@export var end_body: RigidBody2D
@export var pid_controller: PIDController

@export var stretch_lenience := 0
@export var tension_speed := 4000

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not rope or not start_body or not end_body or not pid_controller:
		warnings.append("you are missing a node of one of these types: `MyRope`, `RigidBody2D`, `RigidBody2D`, `PIDController`")
	return warnings

func _ready() -> void:
	var w := _get_configuration_warnings()
	if w:
		push_warning(w)
	if rope:
		rope.connect("rope_stretched", _on_stretch)

func add_rope_realtime(rope_a: MyRope) -> void:
	rope = rope_a
	rope.connect("rope_stretched", _on_stretch)

func _on_stretch(stretch_length: float, start_direction: Vector2, end_direction: Vector2, delta: float) -> void:
	if not start_body or not end_body:
		return
	stretch_length -= stretch_lenience
	if stretch_length <= 0:
		pid_controller.reset()
		return
	
	var impulse := tension_speed * -pid_controller.update(stretch_length, 0, delta)
	start_body.apply_impulse(impulse * start_direction * delta, start_body.global_transform.basis_xform(rope.offset))
	end_body.apply_central_impulse(impulse * -end_direction * delta)
	
	
	
	#var force := stretch_length * elasticity 
	#var dir := end_body.global_position.direction_to(start_body.global_position + rope.offset)
	
	
		#start_body.linear_damp = _start_damp
		#end_body.linear_damp = _end_damp
		#return
	
	#var extra_damping := (stretch_length / rope.rope_length) * damping
	#start_body.linear_damp = _start_damp + extra_damping
	#end_body.linear_damp = _end_damp + extra_damping
