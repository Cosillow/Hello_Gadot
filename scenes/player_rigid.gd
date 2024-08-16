extends RigidBody2D

@export var thrust = Vector2(50, 0)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		state.apply_force(thrust*direction)
	else:
		state.apply_force(Vector2.ZERO)
