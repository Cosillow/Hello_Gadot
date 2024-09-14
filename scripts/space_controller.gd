class_name SpaceController
extends RigidBody2D

@export var thrust: float = 1000 :
	set(val):
		thrust = val
		_thrust_vector = Vector2(val, val)

var _thrust_vector := Vector2.ZERO

func _ready() -> void:
	_thrust_vector = Vector2(thrust, thrust)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	state.apply_central_force(_thrust_vector * dir)
