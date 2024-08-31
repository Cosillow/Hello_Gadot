extends Control
class_name Menu

var off_screen := -5000
var tween: Tween = null
@onready var attached_anim_body: AnimatableBody2D = %AttachedAnimBody
@onready var detach_btn: Button = %Detach
@onready var collisions_btn: Button = %Collisions
@onready var anim_holder: Node2D = %AnimHolder
@onready var rope_sling: CharacterRope = %RopeSling
@onready var v_box_rope: VBoxContainer = %VBoxRope
@onready var v_box_player: VBoxContainer = %VBoxPlayer
@onready var my_controller: SpaceController = %MyController

var mask := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.x += off_screen
	detach_btn.connect("pressed", detach)
	collisions_btn.connect("pressed", collision)
	mask = rope_sling.mask
	for c in v_box_rope.get_children():
		if c is SpinBox:
			var property := c.name
			c.value = rope_sling[property]
			c.prefix = property + " "
			c.connect("value_changed", _on_spinbox_changed.bind(property, rope_sling))
	for c in v_box_player.get_children():
		if c is SpinBox:
			var property := c.name
			c.value = my_controller[property]
			c.prefix = property + " "
			c.connect("value_changed", _on_spinbox_changed.bind(property, my_controller))

func _kill() -> void:
	tween = null

func _on_spinbox_changed(value: float, name: StringName, object: Node2D) -> void:
	object[name] = value

func detach() -> void:
	if detach_btn.text == "Detach":
		rope_sling.remove_child(attached_anim_body)
		anim_holder.add_child(attached_anim_body)
		detach_btn.text = "Reattach"
	else:
		anim_holder.remove_child(attached_anim_body)
		rope_sling.add_child(attached_anim_body)
		detach_btn.text = "Detach"

func collision() -> void:
	print("1")
	if collisions_btn.text == "Collisions off":
		print("2")
		rope_sling.mask = 0
		collisions_btn.text = "Collisions on"
	else:
		print("3")
		rope_sling.mask = mask
		collisions_btn.text = "Collisions off"

func animate_view() -> void:
	if tween:
		return
	off_screen *= -1
	tween = create_tween()
	tween.tween_property(self, "position:x", position.x + off_screen, .3).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(_kill)
