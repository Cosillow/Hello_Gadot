@tool
class_name CharacterRope
extends CollisionShapeRope

@export_flags_2d_physics var layer := 1 :
	set(val):
		layer = val
		if not char_body: return
		char_body.collision_layer = layer
@export_flags_2d_physics var mask := 1 :
	set(val):
		mask = val
		if not char_body: return
		char_body.collision_mask = mask

@onready var char_body := CharChild.new()

func _ready() -> void:
	super()
	char_body.collision_layer = layer
	char_body.collision_mask = mask
	add_child(char_body, false, InternalMode.INTERNAL_MODE_FRONT)
	_move_segments_within_collisions_object(char_body)
	
func _physics_process(delta: float) -> void:
	super(delta)
	_move_segments_within_collisions_object(char_body)
	
# Internal class for the character body
class CharChild extends CharacterBody2D:
	pass
	#func _physics_process(delta: float) -> void:
		# test for current collisions 
		# TODO: NO INFINITE LOOP COLLIDING WITH SAME SHAPE...
		#while true:
			#var col := move_and_collide(Vector2.ZERO, true) 
			#if not col:
				#break
			#var idx := col.get_collider_shape_index()
			#var normal := col.get_normal()
			#var shape: CollisionShape2D = col.get_local_shape()
			#var seg_i := shape.get_index()
			## TODO: finish the collision affecting rope
