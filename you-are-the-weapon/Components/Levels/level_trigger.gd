@tool
extends Area3D
class_name LevelTrigger


# Empty for now, may need special logic?
@export var size: Vector3 = Vector3.ONE:
	set(new_size):
		if mesh_editor:
			mesh_editor.mesh.set("size", new_size)
		if collision_shape_editor:
			collision_shape_editor.shape.set("size", Vector3(new_size.x + 1, new_size.y + 1, new_size.z + 1))
		size = new_size

@export var untriggered_color: Color = Color(Color.DARK_ORANGE)
@export var triggered_color: Color = Color(Color.LIME_GREEN)

@export_category("Internals")
@export var mesh_editor: MeshInstance3D
@export var collision_shape_editor: CollisionShape3D

signal triggered

func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		mesh_editor.mesh.get("material").set("albedo_color", untriggered_color)
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body is Ball:
		triggered.emit()
		_tween_color()
		body_entered.disconnect(_on_body_entered)
		

func _tween_color():
	var tween = get_tree().create_tween()
	tween.tween_property(mesh_editor.mesh.get("material"), "albedo_color", triggered_color, .5)
