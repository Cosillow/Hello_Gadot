class_name SpaceController

extends RigidBody2D

@export var thrust := Vector2(500, 500)
@export var bounce_ratio: float = 0.1

@onready var rope_sling: Rope = %RopeSling
@onready var attached_body: AnimatableBody2D = %AttachedAnimBody

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var X_DIR = Input.get_axis("move_left", "move_right")
	var Y_DIR = Input.get_axis("move_up", "move_down")
	state.apply_central_force(thrust * Vector2(X_DIR, Y_DIR).normalized())
	
	for i in state.get_contact_count():
		if state.get_contact_collider_object(i) == attached_body:
			var normal = state.get_contact_local_normal(i)
			var relative_velocity = state.get_contact_collider_velocity_at_position(i) - state.get_contact_local_velocity_at_position(i)
			rope_sling.apply_endpoint_impulse(bounce_ratio * (-normal * relative_velocity.length()))
