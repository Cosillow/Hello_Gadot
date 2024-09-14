extends SpaceController

@export var steady_speed: float = 1000
@export var pull_up_impulse: float = 5000
@export var torque_impulse: float = 500
@export var air_angle: float = 45
@export var water_angle: float = 100

@onready var pid_stick_controller: PIDController = %PIDStickController

var _is_in_water := false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super(state)
	var angle := water_angle if _is_in_water else air_angle
	var torque := steady_speed * pid_stick_controller.update_angle(rotation_degrees, angle, state.step)
	
	if Input.is_action_just_pressed("jump"):
		state.apply_torque_impulse(-torque_impulse)
		#state.apply_impulse(-steady_speed / 10000 * -state.transform.x * state.transform.y)
		state.apply_impulse(pull_up_impulse * Vector2.UP)
	
	state.apply_torque(torque)

func _on_water_area_body_entered(body: Node2D) -> void:
	_is_in_water = true
	pid_stick_controller.reset()

func _on_water_area_body_exited(body: Node2D) -> void:
	_is_in_water = false
	pid_stick_controller.reset()
