class_name  Jetpacker
extends RigidBody2D

@export var vertical_pid: PIDController
@export var hover_angle_pid: PIDController
@export var player_controlled_angle_pid: PIDController

@export var hover_thrust: float = 1000
@export var hover_angle_torque: float = 100000
@export var player_angle_torque: float = 100000
@export var additional_y_angle_aim: float = 1000
@export var thrust: float = 5000 :
	set(val):
		thrust = val
		_thrust_vector = Vector2(val, val)

var angle_location: Vector2 :
	get:
		return _intended_location - Vector2(0, additional_y_angle_aim)

var _thrust_vector: Vector2
var _intended_location: Vector2
var _player_angle_aim: float

func _ready() -> void:
	assert(vertical_pid and hover_angle_pid)
	_thrust_vector = Vector2(thrust, thrust)
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# boost jetpack
	if Input.is_action_pressed("jump"):
		state.apply_central_force(_thrust_vector * -transform.y)
	
	# control packer or hover
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var torque: float
	
	# TODO actually do this ... for controller only adjust the angle to a bit if player only tapped toward the direction
	#			MINIMUM - I need an indicator of intended direction?
	
	if dir:
		vertical_pid.reset()
		hover_angle_pid.reset()
		_intended_location = global_position
		
		
		_player_angle_aim = dir.angle() #lerpf(_player_angle_aim, dir.angle(), state.step)
		torque = player_angle_torque * player_controlled_angle_pid.update_angle(rotation_degrees, 90 + rad_to_deg(_player_angle_aim), state.step)
		state.apply_torque(torque)
		
		#state.apply_central_force(_thrust_vector * dir)
	#else:
		#player_controlled_angle_pid.reset()
		#
		#var PID_val := -vertical_pid.update(global_position.y, _intended_location.y, state.step)
		#var force := -transform.y * hover_thrust * PID_val
		#apply_central_force(force)
		#
		## TODO: maybeeee reset the angle pid idk
		#var torque := hover_angle_torque * hover_angle_pid.update_angle(rotation_degrees, 90 + rad_to_deg(get_angle_to(angle_location)), state.step)
		#state.apply_torque(torque)
	
	#queue_redraw()
	
	
	
	
#func _draw() -> void:
	#
	#draw_circle(to_local(_intended_location), 10, Color.AQUAMARINE)
	#draw_line(to_local(global_position), to_local(angle_location), Color.DARK_ORANGE)
