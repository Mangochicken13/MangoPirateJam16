extends Node
class_name Main

@export var menu_ui: Menu
@export var player_ui: PlayerUI

@export var player: Ball

var game_started: bool

func _ready() -> void:
	player_ui.hide()
	menu_ui.start_game.connect(_start_game)
	
	get_tree().paused = true

func _start_game():
	get_tree().paused = false
	menu_ui.hide()
	player_ui.show()
	player.start_moving()
