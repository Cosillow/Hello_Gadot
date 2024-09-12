class_name SpaceController
extends RigidBody2D

# TODO: add rope impulse when attached hits something
# TODO: add controller force (probably not impulse) when attached fully extends 
# 		THIS WILL alreday be finnickey... need to write a solution that works for different end stiffness'
#		and... other things I can't think of rn...

const ROPE_PROJECTILE = preload("res://scenes/rope_projectile.tscn")
const SPACE_ROPE = preload("res://scenes/space_rope.tscn")
const ROPE_SLING = preload("res://scenes/rope_sling.tscn")

@export var thrust: float = 1000 :
	set(val):
		thrust = val
		_thrust_vector = Vector2(val, val)
@export var bounce_ratio: float = 0.1

@onready var rope_sling: RopeSling = %RopeSling

var _thrust_vector := Vector2.ZERO
var _calculated_drag := Vector2.ZERO

func _ready() -> void:
	_thrust_vector = Vector2(thrust, thrust)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var X_DIR := Input.get_axis("move_left", "move_right")
	var Y_DIR := Input.get_axis("move_up", "move_down")
	var dir := Vector2(X_DIR, Y_DIR).normalized()
	
	if Input.is_action_just_pressed("jump"):
		state.apply_central_impulse(1000 * ( dir if dir else state.linear_velocity.normalized() ) )
	
	state.apply_central_force(_calculated_drag + _thrust_vector * dir)
	_calculated_drag = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rope"):
		#call_deferred("_shoot_rope")
		_shoot_rope()

func _shoot_rope() -> void:
	var dir := (get_global_mouse_position() - position).normalized()
	var sling := ROPE_SLING.instantiate() as RopeSling
	
	sling.init_glob_body_pos = global_position + dir * 200
	add_child(sling)
	sling.shoot(dir * 2000 + linear_velocity, self)
	
