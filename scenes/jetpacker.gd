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

@onready var boost: GPUParticles2D = %Boost
@onready var side_thrust_boost_body: GPUParticles2D = %SideThrustBoostBody
@onready var side_thrust_boost_back_jpak: GPUParticles2D = %SideThrustBoostBackJpak

var angle_location: Vector2 :
	get:
		return _intended_location - Vector2(0, additional_y_angle_aim)

var _thrust_vector: Vector2
var _intended_location: Vector2
var _player_angle_aim: float
var _og_particle_boost: float

func _ready() -> void:
	assert(vertical_pid and hover_angle_pid)
	_thrust_vector = Vector2(thrust, thrust)
	_og_particle_boost = boost.amount

#func _process(delta: float) -> void:
	#print(constant_force)
	#if constant_force == Vector2.ZERO:
		
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# boost jetpack
	if Input.is_action_pressed("jump"):
		state.apply_central_force(_thrust_vector * transform.x)
		boost.emitting = true
	else:
		boost.emitting = false
	
	if Input.is_action_just_pressed("rope"):
		state.apply_central_impulse(_thrust_vector * -transform.x)
	
	# control packer or hover
	#var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var torque: float
	
	# TODO actually do this ... for controller only adjust the angle to a bit if player only tapped toward the direction
	#			MINIMUM - I need an indicator of intended direction?
	
	#if dir:
	#vertical_pid.reset()
	#hover_angle_pid.reset()
	#_intended_location = global_position
	
	# TODO: the angle is wrong. it goes the wrong way at (-1, 0)
	_player_angle_aim = rad_to_deg(global_position.angle_to_point(get_global_mouse_position())) #dir.angle() #lerpf(_player_angle_aim, dir.angle(), state.step)
	var pid_factor :=  player_controlled_angle_pid.update_angle(rotation_degrees, _player_angle_aim, state.step)
	state.apply_torque(player_angle_torque * pid_factor)
	if pid_factor > 0:
		side_thrust_boost_back_jpak.emitting = true
		side_thrust_boost_body.emitting = false
	elif pid_factor < 0:
		side_thrust_boost_body.emitting = true
		side_thrust_boost_back_jpak.emitting = false
	
	
	#print(rotation_degrees, "  and  ", _player_angle_aim)
		
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
