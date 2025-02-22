extends Node3D
class_name HealthComponent

@export var MAX_HEALTH: float = 1.0
var health: float

signal health_depleted

@export var gradient: Gradient = base_gradient
const base_gradient: Gradient = preload("res://Components/health_gradient.tres")

const base_material: Material = preload("res://Components/brick_health.material")

func _ready() -> void:
	health = MAX_HEALTH

func _deal_damage(damage: float) -> void:
	health -= damage
	if health <= 0:
		health_depleted.emit()
