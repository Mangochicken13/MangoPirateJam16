extends Wall
class_name BreakableWall

#@export var health_component: HealthComponent

@export var health: float = 1
var max_health: float
@export var defence: float = 0
@export var damage_reduction: float = 0

@export var health_gradient: Gradient
#@export var crack_noise_texture: FastNoiseLite

signal destroyed

func _ready() -> void:
	super._ready()
	max_health = health
	_update_color()
	

func _set_collision_layer() -> void:
	if collision_layer == 1:
		collision_layer = 4

## Returns the final damage dealt after damage reduction and defence
func _deal_damage(incoming_damage: float) -> float:
	
	var final_damage: float = incoming_damage * (1 - damage_reduction)
	final_damage = final_damage - defence
	final_damage = maxf(final_damage, 0.0)
	
	#health_component.damage(final_damage)
	
	health -= final_damage
	if health <= 0:
		_destroy()
	_update_cracks()
	_update_color()
	
	return final_damage

func _update_color() -> void:
	# there has to be a better method to change the color of the texture right?
	mesh_material.set("albedo_color", health_gradient.sample(health/max_health))


func _update_cracks() -> void:
	# call function to make crack/debri particles
	pass

func _destroy() -> void:
	destroyed.emit()
	queue_free()
	#shatter into pieces, still bounce off of the last hit though
	pass
