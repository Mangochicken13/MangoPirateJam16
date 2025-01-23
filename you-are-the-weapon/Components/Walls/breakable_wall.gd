extends Wall
class_name BreakableWall


@export var health: float = 1
@export var defence: float = 0
@export var damage_reduction: float = 0

func _damage(incoming_damage: float) -> float:
	var final_damage = incoming_damage * (1 - damage_reduction)
	final_damage = final_damage - defence
	health = health - final_damage
	_update_cracks()
	return final_damage




func _update_cracks() -> void:
	# call function to make crack/debri particles
	pass
