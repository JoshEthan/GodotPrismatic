extends CharacterBody3D

@onready var camera_controller = $CameraController
@onready var model_controller = $ModelController
@onready var skeleton: Skeleton3D = $ModelController/PlayerSkeleton3D

@export var min_speed = 1.4
@export var max_speed = 8

var SPEED = min_speed
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_velocity = Vector2.ZERO
var current_acceleration: float = 0
var last_acceleration: float = 0
var last_acceleration_tilt: float = -0.298


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle sprinting
	if Input.is_action_pressed("sprint"):
		SPEED = move_toward(SPEED, max_speed, delta)
	else:
		SPEED = move_toward(SPEED, min_speed, delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	move_direction = move_direction.rotated(Vector3.UP, camera_controller.rotation.y).normalized()
	
	last_velocity = velocity
	velocity.x = move_toward( velocity.x, move_direction.x * SPEED, SPEED * delta)
	velocity.z = move_toward( velocity.z, move_direction.z * SPEED, SPEED * delta)
	last_acceleration = current_acceleration
	current_acceleration = (velocity.length() - last_velocity.length()) / delta
	#print(acceleration)

	var acceleration_tilt = map_acceleration_to_value(current_acceleration)
	#acceleration_tilt = move_toward(acceleration_tilt, map_acceleration_to_value(acceleration), delta * .00001)
	var smoothed_acceleration = lerp(last_acceleration, current_acceleration, 0.5)
	last_acceleration_tilt = acceleration_tilt
	acceleration_tilt = lerp(acceleration_tilt, map_acceleration_to_value(smoothed_acceleration), 0.5)
	#acceleration_tilt = lerp(acceleration_tilt, map_acceleration_to_value(acceleration), 0.25)
		
	if velocity.length() > 0.2:
		var look_direction = Vector2(-velocity.z, -velocity.x)
		model_controller.rotation.y = lerp_angle(look_direction.angle(), model_controller.rotation.y, 0.75)

	
	acceleration_tilt = lerp(last_acceleration, -0.289, 0.5)
	print(last_acceleration_tilt)
	skeleton.set_bone_pose_rotation(skeleton.find_bone("spine.001"), Quaternion(acceleration_tilt, 0, 0, 0.954))	
	move_and_slide()
	
func map_acceleration_to_value(acceleration):
	# Normalize acceleration to a [0, 1] range.
	var normalized_acc = abs(acceleration) / 4
	var base_rotation = -0.298

	if acceleration == 0:
		return base_rotation
	elif acceleration > 0:
		# Map positive acceleration to [-0.02, 0.298).
		return base_rotation - normalized_acc * (base_rotation - (-0.01))
	else:
		# Map negative acceleration to (0.298, 0.4].
		return base_rotation + normalized_acc * (-0.3 - base_rotation)

