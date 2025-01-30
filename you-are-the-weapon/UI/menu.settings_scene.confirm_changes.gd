extends PopupPanel
class_name ChangeSettingsConfirmation

@export var cancel_button: Button
@export var confirm_button: Button

var apply_changes: bool = false

func _ready() -> void:
	cancel_button.pressed.connect(_cancel)
	confirm_button.pressed.connect(_confirm)

func _cancel() -> void:
	apply_changes = false
	hide()

func _confirm() -> void:
	apply_changes = true
	hide()
