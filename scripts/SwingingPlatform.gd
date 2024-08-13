extends Node2D
## moves back and forth `distance` from starting position

@export var distance: float = 100 :
	set(val):
		distance = val
		_target.x = distance
		_error.x = 0.05 * distance
@export var time: float = 4
@onready var top_platform: Node2D = $TopPlatform

var _target: Vector2 = Vector2.ZERO
var _error: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
		# Calculate the distance to the target
	var diff = _target - top_platform.position
	
	# Check if the platform is close enough to the target
	if diff.abs().x < _error.x:
		# Reverse the direction
		_target.x = -_target.x
	
	# Move the platform smoothly towards the target
	top_platform.position += diff * time * delta
