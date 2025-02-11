@tool
extends BaseBrick
class_name PrimitiveBrick

enum PRIMITIVE_SHAPES {
	Sphere, # Radius: float
	Box, # Size: Vec3
	Capsule, # Radius: float, Height: float
	Cylinder, # Radius: float, Height: float
	#WorldBoundary # Plane: Plane # Not super useful
}

@export_group("Shape")
@export var primitive_shape: PRIMITIVE_SHAPES = PRIMITIVE_SHAPES.Box:
	set(shape):
		primitive_shape = shape
		_change_shape()
		_update_shape()
		notify_property_list_changed()

## Affects Sphere, Cylinder, and Capsule shapes
@export_range(0.001, 100, 0.001, "or_greater") var radius: float = 0.5:
	set(new_radius):
		radius = new_radius
		if radius * 2 > height and primitive_shape == PRIMITIVE_SHAPES.Capsule:
			height = radius * 2
		_update_shape()
## Affects Cylinder, and Capsule shapes
@export_range(0.001, 100, 0.001, "or_greater") var height: float = 2.0:
	set(new_height):
		height = new_height
		if height / 2 < radius and primitive_shape == PRIMITIVE_SHAPES.Capsule:
			radius = height / 2
		_update_shape()

## Affects Box
@export var size: Vector3 = Vector3.ONE:
	set(new_size):
		for i: int in range(3):
			if new_size[i] < 0.0:
				new_size[i] = 0.01
		size = new_size
		_update_shape()

#@export var plane: Plane = Plane.PLANE_XZ:
	#set(new_plane):
		#plane = new_plane
		#_update_shape()
@export var plane_mesh_size: Vector3 = Vector3(20, 1, 20):
	set(new_size):
		plane_mesh_size = new_size
		_update_shape()

@export_group("References")
@export_tool_button("Reset Collision Shape") var update_hitbox_shape : Callable = reset_collision_shape
@export_tool_button("Get Shape Length") var get_shape_length : Callable = _get_half_shape_diagonal.bind(null)


func reset_collision_shape() -> bool:
	if hitbox_component:
		var children: int = hitbox_component.get_child_count()
		
		if children > 0:
			for i: int in children:
				var child = hitbox_component.get_child(i)
				
				if child is CollisionShape3D:
					var new_shape: Shape3D = _get_primitive_shape(primitive_shape)
					child.shape = new_shape
					if i + 1 < children:
						print("More children than expected in {0}".format([hitbox_component.name]))
					return true
	
	return false

func _change_shape() -> void:
	var shape: Shape3D = _get_primitive_shape(primitive_shape)
	var mesh: Mesh = _get_primitive_mesh(primitive_shape)
	var outline_mesh: Mesh = mesh.duplicate() # has to be a different mesh instance, otherwise changes are synced
	if not shape or not mesh:
		printerr("Invalid shape index passed")
		return
	if not hitbox_component:
		push_warning("No Hitbox in Brick")
		return
	
	
	if hitbox_component.is_primitive and hitbox_component.primitive_collision_shape:
		hitbox_component.primitive_collision_shape.shape = shape
		if mesh_component:
			mesh_component.mesh = mesh
		if mesh_component.outline_mesh:
			mesh_component.outline_mesh.mesh = outline_mesh
	else: 
		push_warning("Hitbox \"%s\" is not marked as primitive " % hitbox_component.name)

func _update_shape() -> void:
	var mesh: Mesh
	var outline_mesh: Mesh
	var collision_shape: Shape3D
	
	if not mesh_component:
		return
	
	if mesh_component.mesh:
		mesh = mesh_component.mesh
		if mesh_component.outline_mesh:
			if mesh_component.outline_mesh.mesh:
				outline_mesh = mesh_component.outline_mesh.mesh
			else:
				# Only add the outline for breakable bricks
				if health_component:
					outline_mesh = mesh.duplicate()
					mesh_component.outline_mesh.mesh = outline_mesh
				
			
		
	if hitbox_component.primitive_collision_shape:
		collision_shape = hitbox_component.primitive_collision_shape.shape
	
	match primitive_shape:
		PRIMITIVE_SHAPES.Sphere:
			if mesh is SphereMesh:
				mesh.radius = radius
				mesh.height = radius * 2
				
			if outline_mesh is SphereMesh:
				outline_mesh.radius = radius + 0.1
				outline_mesh.height = radius * 2 + 0.2
				
			if collision_shape is SphereShape3D:
				collision_shape.radius = radius
				
		PRIMITIVE_SHAPES.Box:
			if mesh is BoxMesh:
				mesh.size = size
				
			if outline_mesh is BoxMesh:
				outline_mesh.size = size + Vector3(0.2, 0.2, 0.2)
				
			if collision_shape is BoxShape3D:
				collision_shape.size = size
				
		PRIMITIVE_SHAPES.Capsule:
			if mesh is CapsuleMesh:
				mesh.height = height
				mesh.radius = radius
				
			if outline_mesh is CapsuleMesh:
				outline_mesh.height = height + 0.2
				outline_mesh.radius = radius + 0.2
				
			if collision_shape is CapsuleShape3D:
				collision_shape.height = height
				collision_shape.radius = radius
				
		PRIMITIVE_SHAPES.Cylinder:
			if mesh is CylinderMesh:
				mesh.height = height
				mesh.top_radius = radius
				mesh.bottom_radius = radius
				
			if outline_mesh is CylinderMesh:
				outline_mesh.height = height + 0.2
				outline_mesh.top_radius = radius + 0.1
				outline_mesh.bottom_radius = radius + 0.1
				
			if collision_shape is CylinderShape3D:
				collision_shape.height = height
				collision_shape.radius = radius
				
		#PRIMITIVE_SHAPES.WorldBoundary:
			#if mesh is BoxMesh:
				#mesh.size = plane_mesh_size
				#
			#if outline_mesh is BoxMesh:
				#outline_mesh.size = plane_mesh_size + Vector3(0.2, 0.2, 0.2)
	
	_update_mesh_material(mesh)
	if health_component:
		_update_outline_mesh_material(outline_mesh)
	
	match primitive_shape:
		#PRIMITIVE_SHAPES.WorldBoundary:
			#mesh_component.position.y = 0 - plane_mesh_size.y / 2.0
		_:
			mesh_component.position.y = 0 # reset to default

func _update_mesh_material(p_mesh: Mesh) -> void:
	var length: float = _get_half_shape_diagonal(p_mesh)
	
	var material: Material = p_mesh.get("material")
	if not material:
		print("no mesh")
		material = base_mesh_health_material.duplicate()
	material.distance_fade_min_distance = _min_brick_dither_dist(length)
	material.set("distance_fade_max_distance", _max_brick_dither_dist(length))
	p_mesh.set("material", material)

func _update_outline_mesh_material(p_outline_mesh: Mesh) -> void:
	# Only apply outline for breakable bricks
	if not health_component:
		return
	
	var length: float = _get_half_shape_diagonal(p_outline_mesh)
	
	var material: Material = p_outline_mesh.get("material")
	if not material:
		material = base_mesh_outline_material.duplicate()
	material.set("distance_fade_min_distance", _min_outline_dither_dist(length))
	material.set("distance_fade_max_distance", _max_outline_dither_dist(length))
	p_outline_mesh.set("material", material)
	

func _get_half_shape_diagonal(p_mesh_shape: Mesh) -> float:
	var mesh: Mesh
	var length: float
	if not p_mesh_shape:
		if mesh_component:
			mesh = mesh_component.mesh
		else:
			return 0
	else:
		mesh = p_mesh_shape
	
	if mesh is SphereMesh:
		length = mesh.radius
	
	if mesh is BoxMesh:
		length = mesh.size.length() / 2
	
	if mesh is CapsuleMesh:
		length = Vector2(mesh.height, mesh.radius * 2).length() / 2
	
	if mesh is CylinderMesh:
		length = Vector2(mesh.height, mesh.bottom_radius * 2).length() / 2
	
	
	print_debug("\nLength: ", length)
	if mesh == mesh_component.mesh:
		print("Brick Dither %2.2f, %2.2f" % [_min_brick_dither_dist(length), _max_brick_dither_dist(length)])
	if mesh_component.outline_mesh:
		if mesh == mesh_component.outline_mesh.mesh:
			print("Outline Dither %2.2f, %2.2f" % [_min_outline_dither_dist(length), _max_outline_dither_dist(length)])
	return length

#region Dither Boundaries

# Pretty jank stuff here, might use a shader instead at some point
func _min_brick_dither_dist(p_length: float) -> float:
	var decrease: float = minf(1.0, p_length * 0.2)
	var distance: float = minf(5.0, p_length - decrease)
	return distance

func _max_brick_dither_dist(p_length: float) -> float:
	var increase: float = minf(5.0, p_length * 0.8)
	var distance: float = minf(7.0, p_length + increase)
	return distance

func _min_outline_dither_dist(p_length: float) -> float:
	var decrease: float = minf(2.0, p_length * 0.3)
	return p_length - decrease

func _max_outline_dither_dist(p_length: float) -> float:
	var increase: float = minf(7.0, p_length * 0.5) + 1
	return p_length + increase

#endregion

func _get_primitive_shape(p_type: PRIMITIVE_SHAPES) -> Shape3D:
	match p_type:
		PRIMITIVE_SHAPES.Sphere:
			return SphereShape3D.new()
		PRIMITIVE_SHAPES.Box:
			return BoxShape3D.new()
		PRIMITIVE_SHAPES.Capsule:
			return CapsuleShape3D.new()
		PRIMITIVE_SHAPES.Cylinder:
			return CylinderShape3D.new()
		#PRIMITIVE_SHAPES.WorldBoundary:
			#return WorldBoundaryShape3D.new()
		var shape:
			print("invalid shape index: %s" % shape)
			return null

func _get_primitive_mesh(p_type: PRIMITIVE_SHAPES) -> Mesh:
	match p_type:
		PRIMITIVE_SHAPES.Sphere:
			var sphere_mesh: SphereMesh = SphereMesh.new()
			sphere_mesh.rings = 16
			sphere_mesh.radial_segments = 32
			return sphere_mesh
		PRIMITIVE_SHAPES.Box:
			return BoxMesh.new()
		PRIMITIVE_SHAPES.Capsule:
			var capsule_mesh: CapsuleMesh = CapsuleMesh.new()
			capsule_mesh.radial_segments = 32
			return capsule_mesh
		PRIMITIVE_SHAPES.Cylinder:
			var cylinder_mesh: CylinderMesh = CylinderMesh.new()
			cylinder_mesh.radial_segments = 32
			return cylinder_mesh
		#PRIMITIVE_SHAPES.WorldBoundary:
			#return BoxMesh.new()
		var shape:
			print_debug("invalid shape index: %s" % shape)
			return null

func _validate_property(p_property: Dictionary) -> void:
	match primitive_shape:
		PRIMITIVE_SHAPES.Sphere:
			match p_property.name:
				#"radius". \
				"height", \
				"size", \
				"plane", \
				"plane_mesh_size":
					p_property.usage = PROPERTY_USAGE_NO_EDITOR
		
		PRIMITIVE_SHAPES.Box:
			match p_property.name:
				"radius", \
				"height", \
				#"size". \
				"plane", \
				"plane_mesh_size":
					p_property.usage = PROPERTY_USAGE_NO_EDITOR
		
		PRIMITIVE_SHAPES.Capsule:
			match p_property.name:
				#"radius", \
				#"height". \
				"size", \
				"plane", \
				"plane_mesh_size":
					p_property.usage = PROPERTY_USAGE_NO_EDITOR
		
		PRIMITIVE_SHAPES.Cylinder:
			match p_property.name:
				#"radius", \
				#"height", \
				"size", \
				"plane", \
				"plane_mesh_size":
					p_property.usage = PROPERTY_USAGE_NO_EDITOR
		
		#PRIMITIVE_SHAPES.WorldBoundary:
			#match p_property.name:
				#"radius", \
				#"height", \
				#"size":
				##"plane", \
				##"plane_mesh_size":
					#p_property.usage = PROPERTY_USAGE_NO_EDITOR
