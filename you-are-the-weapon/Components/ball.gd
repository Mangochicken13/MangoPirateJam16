extends CharacterBody3D
class_name Ball

@export var mesh: MeshInstance3D
@onready var ball_cam: PhantomCamera3D

@export var speed: float = 20
@export var turn_speed: float = 1

const LERP_SPEED: float = 2

func _ready() -> void:
	ball_cam = owner.get_node("BallCamera")
	
	# This line is required to make the controls work as expected before hitting a wall
	# For some reason they are inverted without this, could be a sign that something else is benig done wrong
	# This works for now though
	basis = Basis.looking_at(basis * speed * Vector3.FORWARD)


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
		
		# No need to multiply by delta, the remainder magnitude is already multiplied by it
		move_and_collide(velocity.normalized() * collision.get_remainder().length())
		basis = Basis.looking_at(velocity)
		
	

func _process(delta: float) -> void:
	# Using a lerp here to change the angle of the phantom camera spring arm 
	#   avoids manually changing the angle along with player input, and handles bouncing
	var ball_cam_angle = ball_cam.get_third_person_rotation()
	for i in range(3):
		ball_cam_angle[i] = lerp_angle(ball_cam_angle[i], global_rotation[i], LERP_SPEED * delta)
	ball_cam.set_third_person_rotation(ball_cam_angle)
	#pcam.set_third_person_rotation(lerp(pcam.get_third_person_rotation(), global_rotation, 0.06))
	
