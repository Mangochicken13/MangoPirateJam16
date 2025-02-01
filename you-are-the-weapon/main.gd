extends Node
class_name Main

@export var menu_ui: Menu
@export var player_ui: PlayerUI
@export var win_ui: WinScreen

@export var player: Ball

var total_score: int

var levels_in_scene: int
var levels_completed: int
var current_level: Level

var game_started: bool

func _ready() -> void:
	player_ui.hide()
	win_ui.hide()
	menu_ui.start_game.connect(_start_game)
	SignalBus.level_entered.connect(_on_level_entered)
	SignalBus.level_exited.connect(_on_level_exited)
	SignalBus.restart_game.connect(_on_restart_game)
	
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

#region SignalBus Responses 

func _on_level_entered(p_level: Level):
	if not current_level == p_level:
		current_level = p_level

func _on_level_exited(p_level: Level):
	if current_level == p_level:
		total_score += current_level.level_score
		levels_completed += 1
		
		# TODO: Separate this into a standalone function
		if levels_completed >= levels_in_scene and win_ui:
			player_ui.hide()
			win_ui.score_label.text = "You Scored: " + str(total_score)
			win_ui.show()
			get_tree().paused = true

func _on_restart_game():
	get_tree().reload_current_scene()

#endregion
