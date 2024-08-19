class_name RigidPlayer
extends RigidBody2D

@export var rope_rotation_speed: float = 3
@export var rope_strength := Vector2(350, 0)
@export var air_control:float = 1000
@export var rope_swing: RopeSwing = null

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _process(delta: float) -> void:
	if rope_swing:
		# align the collision and sprite to look like they are swinging from the actual rope
		# the rigid body rotates because of joint2d, so subtract that rotation from total
		var dir := rope_swing.rope.endDirection
		collision_shape.rotation = lerp_angle(collision_shape.rotation, dir.angle() - PI/2 - rotation, delta*rope_rotation_speed)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	if rope_swing:
		if Input.is_action_just_pressed("jump"):
			print(state.linear_velocity, " or.. ", state.get_velocity_at_local_position(global_position))
			rope_swing.detach(state.linear_velocity/15)
			
			rope_swing = null
			state.angular_velocity *= 5
			state.linear_velocity.y *= 2
			var tween = get_tree().create_tween()
			tween.tween_property(collision_shape, "rotation", 0, 1)
		else:
			state.apply_force(rope_strength*direction)
	else:
		state.apply_torque(air_control*direction)

func grab_rope_swing(swing: RopeSwing) -> Node2D:
	if rope_swing:
		return null
	
	rope_swing = swing
	return _get_rope_anchor_node()

func _get_rope_anchor_node() -> Node2D:
	return collision_shape
