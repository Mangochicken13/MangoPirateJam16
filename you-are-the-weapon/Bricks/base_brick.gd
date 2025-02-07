extends Node3D
class_name BaseBrick

@export var health_component: HealthComponent
@export var hitbox_component: HitboxComponent
@export var bounce_component: BounceComponent
@export var combo_component: Node3D
@export var mesh_component: MeshComponent

@export var health_gradient: Gradient
@export var base_mesh_health_material: Material
@export var base_mesh_outline_material: Material

func _ready() -> void:
	if not Engine.is_editor_hint():
		if hitbox_component:
			hitbox_component.recieved_damage.connect(_recieve_damage)
		if health_component:
			health_component.health_depleted.connect(_destroy)
			if mesh_component:
				_update_mesh_color(health_gradient.sample(1))
				

func _recieve_damage(damage: float) -> void:
	if health_component:
		health_component._deal_damage(damage)
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
					override_material = base_mesh_health_material.duplicate()
					override_material.set("albedo_color", p_color)
					mesh_component.set_surface_override_material(i, override_material)
				else:
					override_material.set("albedo_color", p_color)

func _destroy() -> void:
	self.queue_free()
