class_name  Jetpacker
extends RigidBody2D

@export var hover_pid: PIDController


@export var hover_thrust: float = 1000 :
	set(val):
			hover_thrust = val
			_hover_thrust_vector = Vector2(val, val)

@export var thrust: float = 5000 :
	set(val):
		thrust = val
		_thrust_vector = Vector2(val, val)

var _thrust_vector := Vector2.ZERO
var _hover_thrust_vector := Vector2.ZERO
var _intended_location: Vector2


func _ready() -> void:
	assert(hover_pid)
	_thrust_vector = Vector2(thrust, thrust)
	_hover_thrust_vector = Vector2(hover_thrust, hover_thrust)
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir:
		state.apply_central_force(_thrust_vector * dir)
		_intended_location = position
		hover_pid.reset()
		print("controlling", _thrust_vector * dir)
	else:
		print("hovering on:", _intended_location)
		dir = position.direction_to(_intended_location)
		apply_central_force(-dir * _hover_thrust_vector * hover_pid.update(position.distance_to(_intended_location), 0, state.step))
	
	queue_redraw()
	
func _draw() -> void:
	draw_line(position, _intended_location, Color.RED)
