@tool
extends Resource
class_name PrimitiveShape

signal shape_type_changed

enum PRIMITIVE_SHAPES {
	Sphere, # Radius: float
	Box, # Size: Vec3
	Capsule, # Radius: float, Height: float
	Cylinder, # Radius: float, Height: float
}

@export var primitive_shape: PRIMITIVE_SHAPES = PRIMITIVE_SHAPES.Box:
	set(shape):
		primitive_shape = shape
		shape_type_changed.emit()
		notify_property_list_changed()

## Affects Sphere, Cylinder, and Capsule shapes
@export_range(0.001, 100, 0.001, "or_greater") var radius: float = 0.5:
	set(new_radius):
		radius = new_radius
		if radius * 2 > height and primitive_shape == PRIMITIVE_SHAPES.Capsule:
			height = radius * 2
		emit_changed()
## Affects Cylinder, and Capsule shapes
@export_range(0.001, 100, 0.001, "or_greater") var height: float = 2.0:
	set(new_height):
		height = new_height
		if height / 2 < radius and primitive_shape == PRIMITIVE_SHAPES.Capsule:
			radius = height / 2
		emit_changed()

## Affects Box
@export var size: Vector3 = Vector3.ONE:
	set(new_size):
		for i: int in range(3):
			if new_size[i] < 0.0:
				new_size[i] = 0.01
		size = new_size
		emit_changed()


func _validate_property(p_property: Dictionary) -> void:
	match primitive_shape:
		PRIMITIVE_SHAPES.Sphere:
			match p_property.name:
				#"radius". \
				"height", \
				"size":
					p_property.usage = PROPERTY_USAGE_NO_EDITOR
		
		PRIMITIVE_SHAPES.Box:
			match p_property.name:
				"radius", \
				"height":
				#"size". \
					p_property.usage = PROPERTY_USAGE_NO_EDITOR
		
		PRIMITIVE_SHAPES.Capsule:
			match p_property.name:
				#"radius", \
				#"height". \
				"size":
					p_property.usage = PROPERTY_USAGE_NO_EDITOR
		
		PRIMITIVE_SHAPES.Cylinder:
			match p_property.name:
				#"radius", \
				#"height", \
				"size":
					p_property.usage = PROPERTY_USAGE_NO_EDITOR
