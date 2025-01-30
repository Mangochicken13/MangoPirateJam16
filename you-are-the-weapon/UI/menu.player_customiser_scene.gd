extends PanelContainer
class_name PlayerCustomiserUI

@export var main_scene_button: Button

signal return_to_main_scene

func _ready() -> void:
	main_scene_button.pressed.connect(_on_main_scene_button_pressed)

func _on_main_scene_button_pressed():
	return_to_main_scene.emit()
