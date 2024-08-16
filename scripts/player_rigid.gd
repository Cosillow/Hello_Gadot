class_name RigidPlayer
extends RigidBody2D

@export var thrust = Vector2(350, 0)
@export var ropeSwing: RopeSwing = null

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if ropeSwing and Input.is_action_just_pressed("jump"):# and is_on_floor():
		ropeSwing.detach()
		ropeSwing = null
		collision_shape.rotation = rotation
		
		
		
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		state.apply_force(thrust*direction)
	else:
		state.apply_force(Vector2.ZERO)
	if ropeSwing:
		# align the collision and sprite to look like they are swinging from the actual rope
		# the rigid body rotates because of joint2d, so subtract that rotation from total
		var dir := ropeSwing.rope.endDirection
		collision_shape.rotation = dir.angle() - PI/2 - rotation

func get_rope_anchor_node() -> Node2D:
	return collision_shape
