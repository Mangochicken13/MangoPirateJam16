extends StaticBody3D
class_name HitboxComponent

@export var is_primitive: bool = false
@export var primitive_collision_shape: CollisionShape3D

signal recieved_damage(damage: float)

func _deal_damage(damage: float):
	recieved_damage.emit(damage)
