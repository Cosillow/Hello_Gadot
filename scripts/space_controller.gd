class_name SpaceController

# TODO: add rope impulse when attached hits something
# TODO: add controller force (probably not impulse) when attached fully extends 
# 		THIS WILL alreday be finnickey... need to write a solution that works for different end stiffness'
#		and... other things I can't think of rn...

extends RigidBody2D

@export var thrust: float = 1000 :
	set(val):
		thrust = val
		_thrust_vector = Vector2(val, val)
@export var bounce_ratio: float = 0.1
@export var drag_factor: float = 100

@onready var rope_sling: MyRope = %RopeSling
@onready var attached_body: PhysicsBody2D = %AttachedBody

var _thrust_vector := Vector2.ZERO
var _calculated_drag := Vector2.ZERO

func _ready() -> void:
	_thrust_vector = Vector2(thrust, thrust)
	rope_sling.connect("rope_stretched", _on_stretch)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var X_DIR = Input.get_axis("move_left", "move_right")
	var Y_DIR = Input.get_axis("move_up", "move_down")
	state.apply_central_force(_calculated_drag + _thrust_vector * Vector2(X_DIR, Y_DIR).normalized())

func _on_stretch(stretch_length: float) -> void:
	_calculated_drag = drag_factor * stretch_length * rope_sling.start_direction
