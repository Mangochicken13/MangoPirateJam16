extends CharacterBody3D
class_name Ball

@export var mesh: MeshInstance3D
@onready var ball_cam: PhantomCamera3D
@onready var ball_cam_base_spring_length: float
var target_spring_length: float

@export var speed: float = 20
@export var turn_speed: float = 1

@export var damage_multiplier: float = 1

const CAMERA_LERP_SPEED: Vector3 = Vector3(2, 4, 2)
const SPRING_LERP_SPEED: float = 4
const VELOCITY_LERP_SPEED: float = 1
const ADDITIONAL_COLLISIONS: int = 3


func _ready() -> void:
	ball_cam = %BallCamera
	ball_cam_base_spring_length = ball_cam.spring_length
	target_spring_length = ball_cam_base_spring_length
	
	# This line is required to make the controls work as expected before hitting a wall
	# For some reason they are inverted without this, could be a sign that something else is benig done wrong
	# This works for now though
	basis = Basis.looking_at(basis * speed * Vector3.FORWARD)

func _process(delta: float) -> void:
	# Using a lerp here to change the angle of the phantom camera spring arm 
	#   avoids manually changing the angle along with player input, and handles bouncing
	var ball_cam_angle = ball_cam.get_third_person_rotation()
	for i in range(3):
		ball_cam_angle[i] = lerp_angle(ball_cam_angle[i], global_rotation[i], CAMERA_LERP_SPEED[i] * delta)
	ball_cam.set_third_person_rotation(ball_cam_angle)
	
	# TODO: more work needed on this
	target_spring_length = max(ball_cam_base_spring_length, ball_cam_base_spring_length + min(2, sqrt((velocity.length() + 1 - speed) - 1)))
	ball_cam.spring_length = lerp(ball_cam.spring_length, target_spring_length, SPRING_LERP_SPEED * delta)

func _physics_process(delta: float) -> void:
	
	#region Rotation
	
	# I don't entirely understand the rotation functions, but they work so that's good enough
	var turn_dir_x = Input.get_axis("turn_up", "turn_down")
	rotate_object_local(Vector3.MODEL_RIGHT, turn_dir_x * delta)
	velocity = velocity.rotated(basis * Vector3.LEFT, turn_dir_x * delta)
	
	var turn_dir_y = Input.get_axis("turn_right", "turn_left")
	rotate_object_local(Vector3.MODEL_TOP, turn_dir_y * delta)
	velocity = velocity.rotated(basis * Vector3.MODEL_TOP, turn_dir_y * delta)
	
	#endregion
	
	# Change this to allow deceleration if decided as the lose condition
	# Other lose condition options include a timer or a combo/hype system
	#if velocity.length() < 20:
		#velocity = basis * speed * Vector3.FORWARD
	#else:
	velocity = velocity.normalized() * lerp(velocity.length(), speed, VELOCITY_LERP_SPEED * delta)
	
	#region Collision Handling
	
	var collision := move_and_collide(velocity * delta)
	
	for i in ADDITIONAL_COLLISIONS:
		if collision == null:
			break
		
		collision = handle_collision(collision)
		
	#endregion
	

func handle_collision(last_collision: KinematicCollision3D) -> KinematicCollision3D:
	if !last_collision:
		return null
	
	var collider = last_collision.get_collider()
	
	if collider is BreakableWall:
		collider._deal_damage(calculate_damage())
		pass
	
	# Common logic; bouncing, imparted velocity
	if collider is Wall:
		
		var normal = last_collision.get_normal()
		velocity = velocity.bounce(normal)
		velocity = collider._bounce(velocity)
		
		# No need to multiply by delta, the remainder magnitude is already multiplied by it
		var collision = move_and_collide(velocity.normalized() * last_collision.get_remainder().length())
		basis = Basis.looking_at(velocity)
		return collision
	
	return null

func calculate_damage() -> float:
	var damage = max(0.5, (1 + pow(max(0, (velocity.length() - speed)) ** 2, (1.0/3)))) * damage_multiplier
	
	print("Damage: ", damage)
	print("From values: \nVelocity magnitude: {0}\nSpeed: {1}\nDamage Multiplier: {2}\n".format([velocity.length(), speed, damage_multiplier]))
	return damage
	

func start_moving() -> void:
	velocity = basis * speed * Vector3.FORWARD
