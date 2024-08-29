class_name RopeSwing
extends StaticBody2D

@export var attachedBody: RigidBody2D = null
@export var ropeAnchorNode: Node2D = null
@onready var rope: MyRope = %MyRope
@onready var pin_joint: PinJoint2D = $PinJoint2D

func _ready() -> void:
	rope.attached = ropeAnchorNode
	if attachedBody:
		pin_joint.node_b = attachedBody.get_path()

func _process(delta: float) -> void:
	pass

func attach_player(player: RigidPlayer):
	ropeAnchorNode = player.get_rope_anchor_node()
	attachedBody = player
	player.rope = rope

func detach(final_velocity: Vector2 = Vector2.ZERO):
	# TODO: take in final veloctiy to make rope look more realistic on detach
	rope.apply_endpoint_impulse(final_velocity)
	attachedBody = null
	ropeAnchorNode = null
	rope.attached = null
	pin_joint.node_b = ""
	
