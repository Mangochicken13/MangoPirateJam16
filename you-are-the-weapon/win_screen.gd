extends Control
class_name WinScreen

@export var restart_button: Button


func _ready() -> void:
	SignalBus.game_won.connect(_on_game_won)
	restart_button.pressed.connect(request_restart)

func _on_game_won():
	show()
	get_tree().paused = true

func request_restart():
	SignalBus.restart_game.emit()
