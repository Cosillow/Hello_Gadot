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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rope"):
		#call_deferred("_shoot_rope")
		_shoot_rope()

func _shoot_rope() -> void:
	#var dir := (get_global_mouse_position() - position).normalized() # TODO: both options?
	var dir := Input.get_vector("move_left", "move_righ`t", "move_up", "move_down")
	var sling := ROPE_SLING.instantiate() as RopeSling
	var planet := PLANET.instantiate() as RigidBody2D
	
	sling.init_glob_body_pos = global_position + dir * 200
	sling.add_child(planet)
	add_child(sling)
	sling.shoot(dir * 800) #+ linear_velocity
	
