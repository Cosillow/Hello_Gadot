extends RigidBody2D

@export var drag_factor: float = 100
@export var rope_sling: CharacterRope = null

var _calculated_drag := Vector2.ZERO

func _ready() -> void:
	rope_sling.connect("rope_stretched", _on_stretch)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.apply_central_force(_calculated_drag)
	
func _on_stretch(stretch_length: float, start_direction: Vector2, end_direction: Vector2) -> void:
	_calculated_drag = drag_factor * stretch_length * -end_direction
	
