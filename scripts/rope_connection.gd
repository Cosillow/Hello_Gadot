class_name RopeConnection
extends Node

# TODO: push warnings for without a rope

@export var rope: MyRope = null
@export var start_body: RigidBody2D = null
@export var end_body: RigidBody2D = null
@export var drag_factor_start: float = 6
@export var drag_factor_end: float = 41
@export var elasticity := 5.0

func _ready() -> void:
	rope.connect("rope_stretched", _on_stretch)

func _on_stretch(stretch_length: float, start_direction: Vector2, end_direction: Vector2) -> void:
	#var tension_force := elasticity * stretch_length
	if not stretch_length or not start_body or not end_body:
		return
		
	var force_start := drag_factor_start * stretch_length
	#var force_start := start_body.angular_velocity * stretch_length
	start_body.apply_central_force(force_start * end_direction)
	
	var force_end := drag_factor_end * stretch_length
	#var force_end := end_body.angular_velocity * stretch_length
	end_body.apply_central_force(force_end * -start_direction)
