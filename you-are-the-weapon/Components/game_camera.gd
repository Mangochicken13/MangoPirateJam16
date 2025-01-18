extends Node3D

@export var target: Node3D

@export_category("Internals")
@export var camera: Camera3D

func _ready() -> void:
	if target:
		transform = target.transform #- target.basis.z
	pass

func _process(delta: float) -> void:
	if target:
		global_position = lerp(global_position, target.global_position, 0.3)
		basis = target.basis
		#camera.look_at(target.global_position)
		pass
