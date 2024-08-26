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
			#rope_sling.apply_endpoint_impulse(-normal* 30)
			rope_sling.apply_endpoint_impulse(bounce_ratio * (-normal * state.get_contact_local_velocity_at_position(i).length()))
			
			#rope_sling.apply_endpoint_impulse(state.get_contact_local_velocity_at_position(i).bounce(normal))

func _on_attached_collision():
	pass

#func _on_body_entered(body: Node) -> void:
	#print(body, " ... ", linear_velocity)
	#rope_sling.apply_endpoint_impulse(Vector2(1,-1)*linear_velocity)


#func _on_body_exited(body: Node) -> void:
	#rope_sling.apply_endpoint_impulse(-linear_velocity)
