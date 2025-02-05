@tool

extends Wall
class_name SixSidedWall

@export var size: Vector3 = Vector3.ONE:
	set(new_size):
		if mesh_editor:
			mesh_editor.mesh.set("size", new_size)
		if collision_shape_editor:
			collision_shape_editor.shape.set("size", new_size)
		size = new_size

@export var color: Color = Color(1, 1, 1, 254.0/255):
	set(new_color):
		if mesh_editor and new_color != Color(1, 1, 1, 254.0/255):
			mesh_editor.mesh.get("material").set("albedo_color", new_color)
			mesh_editor.mesh.get("material").set("albedo_texture", TYPE_NIL)
		elif mesh_texture:
			mesh_editor.mesh.get("material").set("albedo_color", Color.WHITE)
			mesh_editor.mesh.get("material").set("albedo_texture", mesh_texture)
		color = new_color

var mesh_texture: Texture2D

@export_category("Internals")
@export var mesh_editor: MeshInstance3D
@export var collision_shape_editor: CollisionShape3D

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		var image: Image = Image.load_from_file("res://Walls/testing_wall.png")
		mesh_texture = ImageTexture.create_from_image(image)
	else:
		var image = load("res://Walls/testing_wall.png")
		mesh_texture = image
		
