extends StaticBody3D
class_name Wall

## Multiply incoming object's velocity by this amount
@export var velocity_multiplier: float = 1
@export var combo_modifier: float = 0

var mesh_instance: MeshInstance3D
var mesh: Mesh
var mesh_material: Material
var collision_shape: CollisionShape3D

func _ready() -> void:
	var children = get_children()
	for node in children:
		if node is MeshInstance3D and !mesh_instance:
			mesh_instance = node
			mesh = mesh_instance.mesh
			mesh_material = mesh.get("material")
		elif node is CollisionShape3D and !collision_shape:
			collision_shape = node
	
	_set_collision_layer()

func _set_collision_layer() -> void:
	# Solid Walls
	if collision_layer == 1: #Default value
		collision_layer = 2
	else:
		#print(collision_layer, self)
		pass

func _bounce(velocity: Vector3) -> Vector3:
	velocity = velocity * velocity_multiplier
	return velocity
