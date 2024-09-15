class_name PlanetShooter
extends SpaceController

const ROPE_SLING = preload("res://scenes/rope_sling.tscn")
const PLANET = preload("res://scenes/planet.tscn")

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super(state)
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_just_pressed("jump"):
		state.apply_central_impulse(1000 * ( dir if dir else state.linear_velocity.normalized() ) )

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rope"):
		#call_deferred("_shoot_rope")
		_shoot_rope()

func _shoot_rope() -> void:
	#var dir := (get_global_mouse_position() - position).normalized() # TODO: both options?
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var sling := ROPE_SLING.instantiate() as RopeSling
	var planet := PLANET.instantiate() as RigidBody2D
	
	sling.init_glob_body_pos = global_position + dir * 200
	sling.add_child(planet)
	add_child(sling)
	sling.shoot(dir * 800) #+ linear_velocity
