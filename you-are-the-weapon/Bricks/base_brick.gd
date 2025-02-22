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
@export var combo_component: Node3D

var health_gradient: Gradient
var base_health_material: Material
var base_outline_material: Material

var is_breakable: bool

signal destroyed

func _ready() -> void:
	if health_component:
		health_gradient = health_component.gradient
		
		if mesh_component:
			base_health_material = health_component.base_material
		
	if outline_component:
		base_outline_material = outline_component.base_material
	
	
	if not Engine.is_editor_hint():
		if hitbox_component:
			hitbox_component.recieved_damage.connect(_recieve_damage)
			hitbox_component.collision_layer = Utils.COLLISION_LAYERS.Solid_Walls
			
		if health_component:
			health_gradient = health_component.gradient
			is_breakable = true
			health_component.health_depleted.connect(_destroy)
			
			if mesh_component:
				base_health_material = health_component.base_material
				_update_mesh_color(health_gradient.sample(1))
				
			
		if outline_component:
			base_outline_material = outline_component.base_material

func _recieve_damage(p_damage: float) -> void:
	if health_component:
		health_component._deal_damage(p_damage)
		var health_ratio: float = health_component.health / health_component.MAX_HEALTH
		var health_color: Color = health_gradient.sample(health_ratio)
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
