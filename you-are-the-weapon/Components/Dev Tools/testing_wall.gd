@tool

extends StaticBody3D
class_name Testing_Solid_Wall

@export var size: Vector3 = Vector3.ONE:
	set(new_size):
		if mesh:
			mesh.mesh.set("size", new_size)
		if collision_shape:
			collision_shape.shape.set("size", new_size)
		size = new_size

@export var color: Color = Color.WHITE:
	set(new_color):
		if mesh:
			mesh.mesh.get("material").set("albedo_color", new_color)
		color = new_color


@export_category("Internals")
@export var mesh: MeshInstance3D
@export var collision_shape: CollisionShape3D


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if mesh:
			#print(mesh.mesh.get("size"))
			pass
