extends RigidBody2D

@export var follow_rope_speed: float = 50
@export var drag_factor: float = 100
@export var rope_sling: CharacterRope = null

@onready var my_controller: SpaceController = %MyController

var _calculated_drag := Vector2.ZERO

func _ready() -> void:
	rope_sling.connect("rope_stretched", _on_stretch)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if rope_sling.is_connected("rope_stretched", _on_stretch):
			rope_sling.disconnect("rope_stretched", _on_stretch)
			_calculated_drag = Vector2.ZERO
		else:
			rope_sling.connect("rope_stretched", _on_stretch)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.apply_central_force(_calculated_drag)
	
func _on_stretch(stretch_length: float) -> void:
	_calculated_drag = drag_factor * stretch_length * -rope_sling.endDirection
	
