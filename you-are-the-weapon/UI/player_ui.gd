extends Control
class_name PlayerUI

@export var main_handler : Main
var current_level: Level

@export_category("Internals")
@export var score_lerp_timer: Timer
@export var total_score_label: Label
var total_score_displayed: float
var total_score_target: int
@export var level_score_label: Label
var level_score_displayed: float
var level_score_target: int

@export var objective_display: Label
@export var progress_display: ProgressBar
var target_progress_value: float
@export var time_left_display: Label


func _ready() -> void:
	SignalBus.level_entered.connect(_on_level_entered)
	SignalBus.level_win_condition_met.connect(_on_level_win_conditon_met)
	SignalBus.level_timer_timeout.connect(_on_level_timer_timeout)
	

func _process(_delta: float) -> void:
	if current_level:
		target_progress_value = current_level.completion
		level_score_target = current_level.level_score
		
		
		if current_level.timed:
			time_left_display.text = "%.2f" % current_level.completion_timer.time_left
	
	if main_handler:
		total_score_target = main_handler.total_score
	
	level_score_displayed = lerp(level_score_displayed, float(level_score_target), .1)
	level_score_label.text = str(snappedi(level_score_displayed, 1))
	total_score_displayed = lerp(total_score_displayed, float(total_score_target), .1)
	total_score_label.text = str(roundi(total_score_displayed))
	
	progress_display.value = lerpf(progress_display.value, target_progress_value, .1)

func _on_level_entered(p_level: Level) -> void:
	if current_level == p_level:
		return
	current_level = p_level
	_change_objective()
	
	if current_level.timed:
		show_timer()
	else:
		hide_timer()

func _change_objective(p_win_condition: int = -1):
	var win_condition
	if p_win_condition == -1:
		win_condition = current_level.win_condition
	else:
		win_condition = p_win_condition
	var tween = create_tween()
	tween.tween_property(objective_display, "visible_ratio", 0, 1)
	tween.tween_property(objective_display, "text", current_level.objective_text(p_win_condition), 0)
	tween.tween_property(objective_display, "visible_ratio", 1, 1)

func _on_level_win_conditon_met(p_level: Level):
	if current_level == p_level:
		if current_level.timed and current_level.stop_timer_on_win:
			hide_timer()
		
		_change_objective(Level.WIN_CONDITION.None)

func _on_level_timer_timeout(p_level: Level):
	if current_level == p_level:
		hide_timer()

func hide_timer():
	var tween = create_tween()
	tween.tween_property(time_left_display.label_settings, "font_color", \
	  Color(time_left_display.label_settings.font_color, 0), 1.5)

func show_timer():
	var tween = create_tween()
	tween.tween_property(time_left_display.label_settings, "font_color", \
	  Color(time_left_display.label_settings.font_color, 1), 1.5)
