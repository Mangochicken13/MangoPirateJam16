extends StaticBody3D
class_name Wall

## Multiply incoming object's velocity by this amount
@export var velocity_multiplier: float = 1
@export var combo_modifier: float = 0



func _bounce(velocity: Vector3) -> Vector3:
	velocity = velocity * velocity_multiplier
	return velocity
