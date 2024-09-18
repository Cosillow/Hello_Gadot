class_name  Jetpacker
extends RigidBody2D

@export var vertical_pid: PIDController
@export var angle_pid: PIDController


@export var hover_thrust: float = 1000
@export var angle_torque: float = 1000
@export var additional_y_angle_aim: float = 1000
@export var thrust: float = 5000 :
	set(val):
		thrust = val
		_thrust_vector = Vector2(val, val)

var angle_location :
	get:
		return _intended_location - Vector2(0, additional_y_angle_aim)

var _thrust_vector := Vector2.ZERO
var _intended_location: Vector2

func _ready() -> void:
	assert(vertical_pid and angle_pid)
	_thrust_vector = Vector2(thrust, thrust)
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir:
		state.apply_central_force(_thrust_vector * dir)
		_intended_location = global_position
		vertical_pid.reset()
		angle_pid.reset()
	elif Input.is_action_pressed("jump"):
		state.apply_central_force(_thrust_vector * -transform.y)
	else:
		var PID_val := -vertical_pid.update(global_position.y, _intended_location.y, state.step)
		var force := -transform.y * hover_thrust * PID_val
		apply_central_force(force)
		
		# TODO: maybeeee reset the angle pid idk
		var torque := angle_torque * angle_pid.update_angle(rotation_degrees, 90 + rad_to_deg(get_angle_to(angle_location)), state.step)
		state.apply_torque(torque)
	
	queue_redraw()
	
func _draw() -> void:
	draw_circle(to_local(_intended_location), 10, Color.AQUAMARINE)
	draw_line(to_local(global_position), to_local(angle_location), Color.DARK_ORANGE)
