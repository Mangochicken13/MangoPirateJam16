extends Node3D
class_name BounceComponent

## How much the incoming velocity gets multiplied by
@export var bounce_multiplier: float = 1

func bounce(p_velocity: Vector3) -> Vector3:
	var out_velocity: Vector3 = p_velocity * bounce_multiplier
	return out_velocity
	
