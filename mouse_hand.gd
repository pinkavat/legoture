extends CharacterBody2D

# Singleton reference so that all girders are aware of each other
# (should be a girder-set-specific manager object)

# The girder being dragged by the mouse.
var dragged_girder = null

# Cell index of the drag point, used to snap linkage.
var cell_index : Vector2i

# The Pin Joint used to drag the dragged girder
var drag_pin : PinJoint2D = null

func _ready():
	$CollisionShape2D.shape.radius = Girder.UNIT_SIZE / 2.0


func start_dragging(girder, cell_index_):
	cell_index = cell_index_
	dragged_girder = girder
	if drag_pin:
		drag_pin.queue_free()
		drag_pin = null
		print("Tried to start a drag while dragging!")
	else:
		drag_pin = PinJoint2D.new()
		get_parent().add_child(drag_pin)
		drag_pin.global_position = girder.to_global(Vector2(cell_index) * Girder.UNIT_SIZE)
		drag_pin.node_a = self.get_path()
		drag_pin.node_b = girder.get_path()


func stop_dragging(other_girder, other_cell_index):
	if drag_pin:
		if other_girder:
			# Connect the girders
			
			# force-move second girder into position
			var current_other_dpos = other_girder.to_global(Vector2(other_cell_index) * Girder.UNIT_SIZE)
			var current_dpos = dragged_girder.to_global(Vector2(cell_index) * Girder.UNIT_SIZE)
			other_girder.global_position -= current_other_dpos - current_dpos
			
			# Attach pin
			drag_pin.global_position = current_dpos
			drag_pin.node_a = other_girder.get_path()
		else:
			# Relinquish the drag pin
			drag_pin.queue_free()
	drag_pin = null
	dragged_girder = null


func _physics_process(delta):
	velocity = (get_global_mouse_position() - global_position) / delta
	move_and_slide()
