extends Control
class_name Menu

var off_screen := -5000
var tween: Tween = null
#@onready var collisions_btn: Button = %Collisions
#@onready var rope_sling: RopeSling = %RopeSling
@onready var v_box_rope: VBoxContainer = %VBoxRope
@onready var v_box_player: VBoxContainer = %VBoxPlayer
@onready var my_controller: SpaceController = %MyController

var mask := 0

func _ready() -> void:
	position.x += off_screen
	#collisions_btn.connect("pressed", collision)

func _init_menu() -> void:
	#mask = rope_sling.rope.mask
	#for c in v_box_rope.get_children():
		#if c is SpinBox:
			#var property := c.name
			#c.value = rope_sling.rope[property]
			#c.prefix = property + " "
			#c.connect("value_changed", _on_spinbox_changed.bind(property, rope_sling.rope))
	for c in v_box_player.get_children():
		if c is SpinBox:
			var property := c.name
			c.value = my_controller[property]
			c.prefix = property + " "
			c.connect("value_changed", _on_spinbox_changed.bind(property, my_controller))

func _kill() -> void:
	tween = null

func _on_spinbox_changed(value: float, nm: StringName, object: Node2D) -> void:
	object[nm] = value

#func collision() -> void:
	#print("1")
	#if collisions_btn.text == "Collisions off":
		#print("2")
		#rope_sling.rope.mask = 0
		#collisions_btn.text = "Collisions on"
	#else:
		#print("3")
		#rope_sling.rope.mask = mask
		#collisions_btn.text = "Collisions off"

func animate_view() -> void:
	if tween:
		return
	off_screen *= -1
	if off_screen > 0:
		# opening menu
		_init_menu()
	tween = create_tween()
	tween.tween_property(self, "position:x", position.x + off_screen, .3).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(_kill)
