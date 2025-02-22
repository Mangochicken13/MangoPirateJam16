@tool
extends BaseBrick
class_name PrimitiveBrick

@export var shape: PrimitiveShape:
	set(new_shape):
		if shape:
			if shape.shape_type_changed.is_connected(_change_shape):
				shape.shape_type_changed.disconnect(_change_shape)
			if shape.changed.is_connected(_update_shape):
				shape.changed.disconnect(_update_shape)
		
		shape = new_shape
		if shape != null:
			shape.shape_type_changed.connect(_change_shape)
			shape.changed.connect(_update_shape)

@export_group("Editor Tools")
@export_tool_button("Reset Collision Shape") var update_hitbox_shape_button : Callable = reset_collision_shape
@export_tool_button("Get Shape Length") var get_shape_length_button : Callable = _get_half_shape_diagonal.bind(null)

#region Editor Functions

func _get_primitive_shape(p_type: PrimitiveShape.PRIMITIVE_SHAPES) -> Shape3D:
	match p_type:
		PrimitiveShape.PRIMITIVE_SHAPES.Sphere:
			return SphereShape3D.new()
		PrimitiveShape.PRIMITIVE_SHAPES.Box:
			return BoxShape3D.new()
		PrimitiveShape.PRIMITIVE_SHAPES.Capsule:
			return CapsuleShape3D.new()
		PrimitiveShape.PRIMITIVE_SHAPES.Cylinder:
			return CylinderShape3D.new()
		var invalid_shape:
			push_warning("invalid shape index: %s" % invalid_shape)
			return null

func _get_primitive_mesh(p_type: PrimitiveShape.PRIMITIVE_SHAPES) -> Mesh:
	# Reducing the faces on the round shapes should save rendering time?
	# Boxes should only have 12 polygons in most circumstances
	match p_type:
		PrimitiveShape.PRIMITIVE_SHAPES.Sphere:
			var sphere_mesh: SphereMesh = SphereMesh.new()
			sphere_mesh.rings = 16
			sphere_mesh.radial_segments = 32
			return sphere_mesh
		PrimitiveShape.PRIMITIVE_SHAPES.Box:
			return BoxMesh.new()
		PrimitiveShape.PRIMITIVE_SHAPES.Capsule:
			var capsule_mesh: CapsuleMesh = CapsuleMesh.new()
			capsule_mesh.radial_segments = 32
			return capsule_mesh
		PrimitiveShape.PRIMITIVE_SHAPES.Cylinder:
			var cylinder_mesh: CylinderMesh = CylinderMesh.new()
			cylinder_mesh.radial_segments = 32
			return cylinder_mesh
		var invalid_shape:
			push_warning("invalid shape index: %s" % invalid_shape)
			return null

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
		length = mesh.height / 2
	
	if mesh is CylinderMesh:
		length = Vector2(mesh.height, mesh.bottom_radius * 2).length() / 2
	
	#if mesh_component.outline_mesh:
		#if mesh == mesh_component.outline_mesh.mesh:
			#print_debug("\nLength: ", length)
			#print("Outline Dither %2.2f, %2.2f" % [_min_outline_dither_dist(length), _max_outline_dither_dist(length)])
	
	return length


func reset_collision_shape() -> bool:
	if hitbox_component:
		var children: int = hitbox_component.get_child_count()
		
		if children > 0:
			for i: int in children:
				var child = hitbox_component.get_child(i)
				
				if child is CollisionShape3D:
					var new_shape: Shape3D = _get_primitive_shape(shape.primitive_shape)
					child.shape = new_shape
					if i + 1 < children:
						print("More children than expected in %s" % hitbox_component.name)
					return true
		
	
	return false

func _change_shape() -> void:
	if not hitbox_component:
		return
	
	var new_shape: Shape3D = _get_primitive_shape(shape.primitive_shape)
	var new_mesh: Mesh = _get_primitive_mesh(shape.primitive_shape)
	
	if not new_shape or not new_mesh:
		push_error("Invalid shape index passed")
		return
	
	var new_outline_mesh: Mesh = new_mesh.duplicate() # has to be a different mesh instance, otherwise changes are synced
	
	
	if hitbox_component.is_primitive and hitbox_component.primitive_collision_shape:
		hitbox_component.primitive_collision_shape.shape = new_shape
		if mesh_component:
			mesh_component.mesh = new_mesh
		if outline_component:
			outline_component.mesh = new_outline_mesh
	else: 
		# Important in case these settings get toggled off so i know why nothing is happening
		push_warning("Hitbox \"%s\" is not marked as primitive " % hitbox_component.name)
	
	_update_shape()

func _update_shape() -> void:
	var mesh: Mesh
	var outline_mesh: Mesh
	var collision_shape: Shape3D
	
	if not mesh_component:
		return
	
	if mesh_component.mesh:
		mesh = mesh_component.mesh
		
		if outline_component:
			if outline_component.mesh:
				outline_mesh = outline_component.mesh
			else:
				# Only add the outline for breakable bricks
				if health_component:
					outline_mesh = mesh.duplicate()
					outline_component.mesh = outline_mesh
		
		
	if hitbox_component.primitive_collision_shape:
		collision_shape = hitbox_component.primitive_collision_shape.shape
		
	match shape.primitive_shape:
		PrimitiveShape.PRIMITIVE_SHAPES.Sphere:
			if mesh is SphereMesh:
				mesh.radius = shape.radius
				mesh.height = shape.radius * 2
				
			if outline_mesh is SphereMesh:
				outline_mesh.radius = shape.radius + 0.1
				outline_mesh.height = shape.radius * 2 + 0.2
				
			if collision_shape is SphereShape3D:
				collision_shape.radius = shape.radius
				
		PrimitiveShape.PRIMITIVE_SHAPES.Box:
			if mesh is BoxMesh:
				mesh.size = shape.size
				
			if outline_mesh is BoxMesh:
				outline_mesh.size = shape.size + Vector3(0.2, 0.2, 0.2)
				
			if collision_shape is BoxShape3D:
				collision_shape.size = shape.size
				
		PrimitiveShape.PRIMITIVE_SHAPES.Capsule:
			if mesh is CapsuleMesh:
				mesh.height = shape.height
				mesh.radius = shape.radius
				
			if outline_mesh is CapsuleMesh:
				outline_mesh.height = shape.height + 0.2
				outline_mesh.radius = shape.radius + 0.1
				
			if collision_shape is CapsuleShape3D:
				collision_shape.height = shape.height
				collision_shape.radius = shape.radius
				
		PrimitiveShape.PRIMITIVE_SHAPES.Cylinder:
			if mesh is CylinderMesh:
				mesh.height = shape.height
				mesh.top_radius = shape.radius
				mesh.bottom_radius = shape.radius
				
			if outline_mesh is CylinderMesh:
				outline_mesh.height = shape.height + 0.2
				outline_mesh.top_radius = shape.radius + 0.1
				outline_mesh.bottom_radius = shape.radius + 0.1
				
			if collision_shape is CylinderShape3D:
				collision_shape.height = shape.height
				collision_shape.radius = shape.radius
				
	
	if outline_component:
		_set_outline_dither(outline_mesh)

func _set_outline_dither(p_mesh: Mesh) -> void:
	var material: Material = p_mesh.get("material")
	var length: float = _get_half_shape_diagonal(p_mesh)
	var min_length: float = _min_outline_dither_dist(length)
	var max_length: float = _max_outline_dither_dist(length)
	
	if not material:
		material = base_outline_material.duplicate()
	
	material.set("distance_fade_min_distance", min_length)
	material.set("distance_fade_max_distance", max_length)
	p_mesh.set("material", material)

# Pretty jank stuff here, might use a shader instead at some point
func _min_outline_dither_dist(p_length: float) -> float:
	var decrease: float = minf(2.0, p_length * 0.3)
	return p_length - decrease

func _max_outline_dither_dist(p_length: float) -> float:
	var increase: float = minf(7.0, p_length * 0.5) + 1
	return p_length + increase
