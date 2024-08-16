extends RigidBody2D

@export var thrust = Vector2(350, 0)
@export var rope:Rope = null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		state.apply_force(thrust*direction)
	else:
		state.apply_force(Vector2.ZERO)
	if rope:
		var dir := rope.endDirection
		#print(dir)
		collision_shape.rotation = dir.angle() - PI/2 - rotation
		#rotation = dir.angle() - PI/2
