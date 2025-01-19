extends CharacterBody3D
class_name Ball

@export var mesh: MeshInstance3D
@export var camera_target: Node3D

@export var pcam: PhantomCamera3D

@export var speed: float = 20

func _ready() -> void:
	# This line is required to make the controls work as expected before hitting a wall
	# For some reason they are inverted without this, could be a sign that something else is benig done wrong
	# This works for now though
	basis = basis.looking_at(basis * speed * Vector3.FORWARD)


func _physics_process(delta: float) -> void:
	
	var turn_dir_x = Input.get_axis("turn_up", "turn_down")
	rotate_object_local(Vector3.MODEL_RIGHT, turn_dir_x * delta)
	
	var turn_dir_y = Input.get_axis("turn_right", "turn_left")
	rotate_object_local(Vector3.MODEL_TOP, turn_dir_y * delta)
	
	# Constant velocity for now, change this to allow deceleration if decided as the lose condition
	# Other lose condition options include a timer or a combo/hype system
	velocity = basis * speed * Vector3.FORWARD
	
	var collision = move_and_collide(velocity * delta)
	# Bounce function: Needs to be moved to a seperate function call to handle different wall types
	if collision:
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal)
		
		basis = basis.looking_at(velocity)
		
	

func _process(delta: float) -> void:
	# Using a lerp here to change the angle of the phantom camera spring arm 
	#   avoids manually changing the angle along with player input, and handles bouncing
	var pcam_angle = pcam.get_third_person_rotation()
	for i in range(3):
		pcam_angle[i] = lerp_angle(pcam_angle[i], global_rotation[i], 0.06)
	pcam.set_third_person_rotation(pcam_angle)
	#pcam.set_third_person_rotation(lerp(pcam.get_third_person_rotation(), global_rotation, 0.06))
	
