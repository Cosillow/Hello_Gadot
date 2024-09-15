class_name TensionRope
extends Node2D

## necessary children
var rope_connection: RopeConnection
var attachment_rope: MyRope
var attached_body: RigidBody2D

var init_glob_body_pos := Vector2.ZERO

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if get_parent() is not RigidBody2D:
		warnings.append("Parent must be type `RigidBody2d`")
	
	var special_num := 3
	for c in get_children():
		# can't have more than one of must haves
		var illegal := \
				(c is RopeConnection and rope_connection) or \
				(c is MyRope and attachment_rope) or \
				(c is RigidBody2D and attached_body)
		var legal := c is RopeConnection or c is MyRope or c is RigidBody2D
		if illegal:
			warnings.append("You must only have one of each type: `RigidBody2d`, `MyRope`, `RopeConnection`")
		elif legal:
			special_num -= 1
	if special_num != 0:
		warnings.append("You must add a child of type: `RigidBody2d`, `MyRope`, `RopeConnection`")
	
	return warnings

func _ready() -> void:
	for c in get_children():
		var warnings := _get_configuration_warnings()
		if warnings:
			push_error(warnings)
			assert(0)
	
	var parent := get_parent() as RigidBody2D
	for c in get_children():
		if c is RigidBody2D:
			attached_body = c as RigidBody2D
		elif c is MyRope:
			attachment_rope = c as MyRope
		elif c is RopeConnection:
			rope_connection = c as RopeConnection
	
	rope_connection.start_body = parent
	rope_connection.end_body = attached_body
	
	attached_body.global_position = init_glob_body_pos
	
	attachment_rope.attached = attached_body

func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_CHILD_ORDER_CHANGED:
		update_configuration_warnings()

func shoot(impulse: Vector2) -> void:
	attached_body.apply_impulse(impulse)
	#rope_connection.end_body = attached_body
	#attachment_rope.attached = attached_body
