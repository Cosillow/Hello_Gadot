class_name RopeSling
extends Node2D

@onready var rope_connection: RopeConnection = %RopeConnection
@onready var attachment_rope: CharacterRope = %AttachmentRope

var attached_body: RigidBody2D = null
var init_glob_body_pos := Vector2.ZERO
	
func _ready() -> void:
	var count: int = 0
	for c in get_children():
		if c is RigidBody2D:
			count += 1
			attached_body = c as RigidBody2D
	assert(count == 1)
	var parent := get_parent() as RigidBody2D
	assert(parent)
	rope_connection.start_body = parent
	rope_connection.end_body = attached_body
	
	remove_child(attached_body)
	rope_connection.add_child(attached_body)
	
	attached_body.global_position = init_glob_body_pos
	
	attachment_rope.attached = attached_body
	

func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_CHILD_ORDER_CHANGED:
		update_configuration_warnings()


func _get_configuration_warnings():
	var warnings = []
	
	if get_parent() is not RigidBody2D:
		warnings.append("Parent must be type `RigidBody2d`")
	
	for c in get_children():
		if c is not RigidBody2D:
			warnings.append("You must add a child of type `RigidBody2d`")
			break
	
	return warnings

func shoot(impulse: Vector2) -> void:
	attached_body.apply_impulse(impulse)
	rope_connection.end_body = attached_body
	attachment_rope.attached = attached_body
