extends CharacterBody3D
class_name Ball

@export var mesh: MeshInstance3D

@export var speed: float = 20

func _ready() -> void:
	#velocity = Vector3(0, 0, speed)
	pass


func _physics_process(delta: float) -> void:
	
	var turn_dir_x = Input.get_axis("turn_up", "turn_down")
	rotate_object_local(Vector3.MODEL_RIGHT, turn_dir_x * delta)
	
	var turn_dir_y = Input.get_axis("turn_right", "turn_left")
	rotate_object_local(Vector3.MODEL_TOP, turn_dir_y * delta)
	
	velocity = basis * speed * Vector3.FORWARD
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.get_normal()
		print("normal: {0}".format([normal]))
		print("velocity before: {0}".format([velocity]))
		velocity = velocity.bounce(normal)
		print("veloctity after: {0}".format([velocity]))
		print("basis before: {0}".format([basis]))
		basis = Basis.looking_at(velocity)
		print("basis after:  {0}".format([basis]))
		print("")
	pass
