@tool
extends Node3D
class_name BaseBrick

@export var hitbox_component: HitboxComponent:
	set(new_value):
		hitbox_component = new_value
		update_configuration_warnings()
@export var mesh_component: MeshComponent
@export var outline_component: OutlineComponent

@export_category("Extras")

@export var health_component: HealthComponent
@export var bounce_component: BounceComponent
@export var combo_component: ComboComponent

const base_health_material: Material = preload("res://Components/brick_health.material")
const base_outline_material: Material = preload("res://Components/brick_outline.material")

var is_breakable: bool

signal destroyed

func _ready() -> void:
	if not Engine.is_editor_hint():
		if hitbox_component:
			hitbox_component.recieved_damage.connect(_recieve_damage)
			hitbox_component.collision_layer = Utils.COLLISION_LAYERS.Solid_Walls
			
		if health_component:
			is_breakable = true
			health_component.health_depleted.connect(_destroy)
			
			if mesh_component:
				_update_mesh_color(health_component.gradient.sample(1))

func _recieve_damage(p_damage: float) -> void:
	if health_component:
		health_component._deal_damage(p_damage)
		var health_ratio: float = health_component.health / health_component.MAX_HEALTH
		var health_color: Color = health_component.gradient.sample(health_ratio)
		if mesh_component:
			_update_mesh_color(health_color)

func _update_mesh_color(p_color: Color) -> void:
	if mesh_component:
			var override_count: int = mesh_component.get_surface_override_material_count()
			for i: int in override_count:
				var override_material: Material = mesh_component.get_surface_override_material(i)
				if not override_material:
					override_material = base_health_material.duplicate()
					override_material.set("albedo_color", p_color)
					mesh_component.set_surface_override_material(i, override_material)
				else:
					override_material.set("albedo_color", p_color)

func _destroy() -> void:
	destroyed.emit()
	self.queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var err: PackedStringArray = []
	
	if not hitbox_component:
		err.append("No hitbox attached; Collisions will not be detected")
	
	return err

func _get_property_list() -> Array[Dictionary]:
	var arr: Array[Dictionary] = []
	if health_component:
		var health_properties: Array[Dictionary] = health_component.get_script().get_script_property_list()
		for property: Dictionary in health_properties:
			print(property)
			property.usage ^= PROPERTY_USAGE_NO_INSTANCE_STATE
			arr.append(property)
	
	return arr

func _get(property: StringName) -> Variant:
	if health_component:
		if (property == "MAX_HEALTH"):
			return health_component.MAX_HEALTH
		
		if (property == "gradient"):
			return health_component.gradient
	
	return

func _set(property: StringName, value: Variant) -> bool:
	if health_component:
		if (property == "MAX_HEALTH"):
			health_component.MAX_HEALTH = value
			return true
		if (property == "gradient"):
			health_component.gradient = value
			return true
	
	return false

func _validate_property(property: Dictionary) -> void:
	pass
