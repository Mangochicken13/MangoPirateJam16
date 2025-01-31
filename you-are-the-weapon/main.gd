extends Node
class_name Main

@export var menu_ui: Menu
@export var player_ui: PlayerUI
@export var win_ui: WinScreen

@export var player: Ball

var total_score: int

var levels_in_scene: int
var levels_completed: int
var game_started: bool

func _ready() -> void:
	player_ui.hide()
	win_ui.hide()
	menu_ui.start_game.connect(_start_game)
	SignalBus.level_exited.connect(exit_level)
	SignalBus.restart_game.connect(_restart_game)
	
	get_levels(self)
	
	get_tree().paused = true

func get_levels(node: Node):
	for i in node.get_child_count():
		var child = node.get_child(i)
		if child.get_child_count() > 0:
			get_levels(child)
		if child is Level:
			levels_in_scene += 1

func _start_game():
	get_tree().paused = false
	menu_ui.hide()
	player_ui.show()
	player.start_moving()

func exit_level(level: Level):
	total_score += level.level_score
	levels_completed += 1
	if levels_completed >= levels_in_scene and win_ui:
		win_ui.score_label.text = "You Scored: " + str(total_score)
		win_ui.show()
		get_tree().paused = true

func _restart_game():
	get_tree().reload_current_scene()
