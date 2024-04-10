extends Node3D

var LOOKAROUND_SPEED = 0.01

# accumulators
var rot_x = 0
var rot_y = 0

var pitch_max = 6.5
var pitch_min = 0

func _input(event):
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x -= event.relative.x * LOOKAROUND_SPEED ## YAW
		rot_y -= event.relative.y * LOOKAROUND_SPEED ## PITCH
		rot_y = clampf(rot_y, -1.12, 0.16)
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


