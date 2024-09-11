class_name RopeSling
extends Node2D

@onready var attached_body: RigidBody2D = %AttachedBody
@onready var attachment_rope: CharacterRope = %AttachmentRope

var init_glob_body_pos := Vector2.ZERO
	
func _ready() -> void:
	attached_body.global_position = init_glob_body_pos
	
func shoot(impulse: Vector2) -> void:
	attached_body.apply_impulse(impulse)
