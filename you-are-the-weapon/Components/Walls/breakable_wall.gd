extends Wall
class_name BreakableWall


@export var health: float = 1
var max_health: float
@export var defence: float = 0
@export var damage_reduction: float = 0

@export var crack_noise: Resource

var max_health_color: Color = Color.WEB_GREEN
var min_health_color: Color = Color.DARK_RED

func _ready() -> void:
	super._ready()
	max_health = health
	# Breakable Walls
	collision_layer = 4
	

func _damage(incoming_damage: float) -> float:
	var final_damage = incoming_damage * (1 - damage_reduction)
	final_damage = final_damage - defence
	health = health - final_damage
	_update_cracks()
	_update_color()
	return final_damage

func _update_color() -> void:
	mesh_material.set("albedo_color", lerp(max_health_color, min_health_color, health/max_health))


func _update_cracks() -> void:
	# call function to make crack/debri particles
	pass
