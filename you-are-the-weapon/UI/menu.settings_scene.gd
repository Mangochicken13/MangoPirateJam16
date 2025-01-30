extends PanelContainer
class_name SettingsUI

@export var main_scene_button: Button
@export var confirmation_popup: ChangeSettingsConfirmation

@export var settings_container: ScrollContainer
#@export var game_speed_slider: HSlider

var config: ConfigFile

var current_settings: Dictionary = {}
var new_settings: Dictionary = {}

signal return_to_main_scene

func _ready() -> void:
	config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	
	if not err == OK:
		config = ConfigFile.new()
		for i in settings_container.get_child_count():
			var child = settings_container.get_child(i)
			if child.has_signal("changed") and child.get("value"):
				config.set_value("Settings", child.name, child.value)
	
	main_scene_button.pressed.connect(_confirm_changes)
	for i in settings_container.get_child_count():
		var child = settings_container.get_child(i)
		if child.has_signal("changed") and child.get("value"):
			child.changed.connect(_update_settings.bind(child.name, child.value))

func _confirm_changes():
	confirmation_popup.position = get_viewport_rect().size / 2
	confirmation_popup.show()
	await confirmation_popup.popup_hide
	var apply_changes: bool = confirmation_popup.apply_changes
	if apply_changes:
		current_settings = new_settings
		for key in current_settings:
			config.set_value("Settings", key, current_settings[key])
	
	new_settings = current_settings.duplicate(true)
	return_to_main_scene.emit()

func _update_settings(key: String, value: Variant):
	new_settings[key] = value


func load_config() -> void:
	pass
