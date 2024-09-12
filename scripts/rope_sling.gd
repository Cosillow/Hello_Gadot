class_name RopeSling
extends Node2D

@onready var attached_body: RigidBody2D = %AttachedBody
@onready var rope_connection: RopeConnection = %RopeConnection

var init_glob_body_pos := Vector2.ZERO
	
func _ready() -> void:
	attached_body.global_position = init_glob_body_pos
	
func shoot(impulse: Vector2, parent: RigidBody2D=null) -> void:
	attached_body.apply_impulse(impulse)
	rope_connection.start_body = parent
