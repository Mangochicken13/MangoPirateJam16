extends Control
class_name WinScreen

@export var restart_button: Button
@export var score_label: Label

signal game_restart_requested

func _ready() -> void:
	restart_button.pressed.connect(request_restart)

func request_restart() -> void:
	game_restart_requested.emit()
