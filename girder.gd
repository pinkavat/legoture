extends RigidBody2D
class_name Girder

## Girder, of variable shape.

## Size of a girder cell
const UNIT_SIZE := 50.0


enum HOLE_TYPE {
	NONE,	# Girder not present at this point
	PIN,	# Round hole for free rotation
	CROSS,	# Axle hole for constrained rotation
}

## 2D grid of hole positions, of HOLE_TYPE value
var holes : Array

## If girder is being dragged, this is the cell that the mouse is 'holding'
var drag_index # Vector2i, possibly null.


func _init(holes_ : Array):
	# TODO: dynamic rebuild of the structure is subject to some
	# considerations, such as what should happen to existing joints.
	# May require fundamentally different data-structure.
	
	holes = holes_.duplicate()
	
	# Disable intrastructure collision
	collision_layer = 0b10
	
	# TODO: connect mouse-detection signals. At present system uses
	# expensive per-move check.
	
	# Build colliders
	var collider_circle = CircleShape2D.new()
	collider_circle.radius = UNIT_SIZE / 2.0
	var coll_pos = Vector2.ZERO
	for row in holes:
		for col in row:
			
			if col != HOLE_TYPE.NONE:
				var collider = CollisionShape2D.new()
				collider.shape = collider_circle
				collider.position = coll_pos
				add_child(collider)
			
			coll_pos.x += UNIT_SIZE
		coll_pos.x = 0
		coll_pos.y += UNIT_SIZE
	
	# Draw girder structure
	queue_redraw()


func _draw():
	pass


## Checks the mouse position against all pin positions, and returns a Vector2i of the
## moused-over pin, or null if the girder isn't moused over. 
func _get_mouse_girder_index():
	var local_mouse_pos = get_local_mouse_position()
	var unit_radius_squared = (UNIT_SIZE / 2.0) ** 2.0
	
	# TODO duplicate code against collider creation
	var cell_index = Vector2i.ZERO
	for row in holes:
		for col in row:
			
			var cell_pos = UNIT_SIZE * Vector2(cell_index)
			if col != HOLE_TYPE.NONE and (local_mouse_pos - cell_pos).length_squared() < unit_radius_squared:
				return cell_index
			
			cell_index.x += 1
		cell_index.x = 0
		cell_index.y += 1
	
	return null


func _input(event):
	if event is InputEventMouseMotion:
		if MouseHand.dragged_girder == self:
			# This girder is the one being dragged
			#get_viewport().set_input_as_handled()
			pass
		else:
			pass # TODO: highlight pin
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Left mouse down
				drag_index = _get_mouse_girder_index()
				if drag_index != null and MouseHand.dragged_girder == null:
					# Drag ourselves
					get_viewport().set_input_as_handled()
					MouseHand.start_dragging(self, drag_index)
					#can_sleep = false
				
			else:
				# Left mouse up
				drag_index = _get_mouse_girder_index()
				if drag_index != null and MouseHand.dragged_girder != self:
					# Mouse up on us, with another girder dragged
					get_viewport().set_input_as_handled()
					MouseHand.stop_dragging(self, drag_index)
				#can_sleep = true

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if MouseHand.dragged_girder == self:
			# If mouse released and no other girder in contact
			get_viewport().set_input_as_handled()
			MouseHand.stop_dragging(null, null)


#func _integrate_forces(state):
#	if MouseHand.dragged_girder == self:
#		var drag_point_local = Vector2(drag_index) * UNIT_SIZE
#		var global_drag = to_global(get_local_mouse_position() - drag_point_local) - global_position
#		state.linear_velocity = global_drag / state.step
#
#		# TODO ANGULAR VELOCITY

#func _physics_process(delta):
#	# If dragged, apply a drag force
#	if MouseHand.dragged_girder == self:
#		var drag_point_local = Vector2(drag_index) * UNIT_SIZE
#		var global_drag = to_global(get_local_mouse_position() - drag_point_local) - global_position
#		# Cheap-n-cheerful distance-varying force
#		var MAX_FORCE_DIST = 30.0
#		var MAX_FORCE = 1000.0
#		var force_mag = min(MAX_FORCE, remap(global_drag.length(), 0.0, MAX_FORCE_DIST, 0.0, MAX_FORCE))
#		apply_force(force_mag * global_drag.normalized(), to_global(drag_point_local) - global_position)
#		#apply_force(global_drag.normalized() * 10.0, to_global(drag_point_local) - global_position)
