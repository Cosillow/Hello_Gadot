extends RigidBody2D


@export var thrust: float = 1000 :
	set(val):
		thrust = val
		_thrust_vector = Vector2(val, val)

var _thrust_vector := Vector2.ZERO

func _ready() -> void:
	_thrust_vector = Vector2(thrust, thrust)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var X_DIR = Input.get_axis("move_left", "move_right")
	var Y_DIR = Input.get_axis("move_up", "move_down")
	state.apply_central_force(_thrust_vector * Vector2(X_DIR, Y_DIR).normalized())
	
