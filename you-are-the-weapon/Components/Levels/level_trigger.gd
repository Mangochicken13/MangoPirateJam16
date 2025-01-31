@tool
extends Area3D
class_name LevelTrigger


# Empty for now, may need special logic?
@export var size: Vector3 = Vector3.ONE:
	set(new_size):
		if mesh_editor:
			mesh_editor.mesh.set("size", new_size)
		if collision_shape_editor:
			collision_shape_editor.shape.set("size", new_size)
		size = new_size

@export var untriggered_color: Color = Color(Color.DARK_ORANGE, 128.0/255)
@export var triggered_color: Color = Color(Color.LIME_GREEN, 128.0/255) 

@export_category("Internals")
@export var mesh_editor: MeshInstance3D
@export var collision_shape_editor: CollisionShape3D


func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		mesh_editor.mesh.albedo_color = untriggered_color
		body_entered.connect(_tween_color)

func _tween_color():
	var tween = get_tree().create_tween()
	tween.EaseType = Tween.EASE_IN_OUT
	tween.tween_property(mesh_editor.mesh, "albedo_color", triggered_color, 1)
