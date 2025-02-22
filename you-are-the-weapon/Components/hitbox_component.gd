extends StaticBody3D
class_name HitboxComponent

# This is jank, maybe split this component into two?
@export var is_primitive: bool = false
@export var primitive_collision_shape: CollisionShape3D

signal recieved_damage(damage: float)

func _deal_damage(damage: float) -> void:
	recieved_damage.emit(damage)
