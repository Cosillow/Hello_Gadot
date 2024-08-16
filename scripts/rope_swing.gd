class_name RopeSwing
extends StaticBody2D

@export var attachedBody: RigidBody2D = null
@export var ropeAnchorNode: Node2D = null
@onready var rope: Rope = $Rope
@onready var pin_joint: PinJoint2D = $PinJoint2D

func _ready() -> void:
	rope.attached = ropeAnchorNode
	pin_joint.node_b = attachedBody.get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func attach_player(player: RigidPlayer):
	ropeAnchorNode = player.get_rope_anchor_node()
	attachedBody = player
	player.rope = rope

func detach():
	attachedBody = null
	ropeAnchorNode = null
	rope.attached = null
	pin_joint.node_b = ""
	
