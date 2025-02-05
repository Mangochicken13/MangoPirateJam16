extends Control
class_name WinScreen

@export var restart_button: Button
@export var score_label: Label


func _ready() -> void:
	restart_button.pressed.connect(request_restart)

func request_restart():
	SignalBus.restart_game.emit()
