extends Node3D
class_name HealthComponent

@export var MAX_HEALTH: float = 1.0
var health: float

signal health_depleted

const GRADIENT: Gradient = preload("res://Components/health_gradient.tres")

func _ready() -> void:
	health = MAX_HEALTH

func _deal_damage(damage: float) -> void:
	health -= damage
	if health <= 0:
		health_depleted.emit()
