@tool
extends Node3D
class_name Level


enum WIN_CONDITION { ## The condition to meet for the exit to enable
	None, ## No condition
	Brick_percentage, ## Break [member brick_percentage] of bricks in the level
	Brick_num, ## Break [member brick_num] bricks in the level (must be less than or equal to the total number of bricks)
	Trigger_percentage, ## Enter/meet [member trigger_percentage] of triggers
	Trigger_num, ## Enter/meet [member trigger_num] of triggers (must be less than or equal to the total number of triggers) 
}

#region Export vars

@export var win_condition: WIN_CONDITION:
	set(condition):
		win_condition = condition
		notify_property_list_changed()

@export_range(0, 100, 1, "suffix:%") var brick_percentage: int = 60
@export_range(0, 255, 1, "or_greater") var brick_num: int:
	set(num):
		bricks_in_level = get_breakable_bricks()
		if num > bricks_in_level:
			brick_num = bricks_in_level
			print("Variable \"Brick Num\" cannot exceed the number of bricks in the scene (%s)" % bricks_in_level)
			return
		
		brick_num = num

@export_range(0, 100, 1, "suffix:%") var trigger_percentage: int = 100
@export_range(0, 255, 1, "or_greater") var trigger_num: int:
	set(num):
		triggers_in_level = get_triggers()
		if num > triggers_in_level:
			trigger_num = triggers_in_level
			print("Variable \"Trugger Num\" cannot exceed the number of bricks in the scene (%s)" % triggers_in_level)
			return
		
		trigger_num = num

## If the selected win condition has a time to complete it within.
## Using this in conjunction with [enum WIN_CONDITION.None] 
##will give the player [member time] seconds to reach the exit
@export var timed: bool = false:
	set(value):
		timed = value
		notify_property_list_changed()

## Whether to stop counting down the timer once the condition is met.
## Setting this to [code]false[/code] means the player has to reach the exit after completing 
## This does nothing if the condition is [enum WIN_CONDITION.None]
@export var stop_timer_on_win: bool = true
@export var time: float = 120

@export var score_multiplier: float = 1

@export_category("References")
@export var exit_trigger: Area3D
@export var trigger_holder: Node
@export var breakable_bricks_holder: Node
@export var solid_walls_holder: Node

@export var completion_timer: Timer

@export var boundary: AABB

#endregion

var win_condition_met: bool = false

var bricks_in_level: int = 0
var bricks_destroyed: int = 0

var triggers_in_level: int = 0
var triggers_activated: int = 0

var level_score: int = 0
var time_bonus: int = 0
var completion_bonus: int = 0

#region Signals

signal level_finished
signal condition_met

#endregion

func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		if exit_trigger:
			exit_trigger.body_entered.connect(try_finish_level)
		else:
			push_error("No exit for level ", get_tree().current_scene.scene_file_path.get_file().get_basename())
		
		bricks_in_level = get_breakable_bricks()
		triggers_in_level = get_triggers()
		
		for node in breakable_bricks_holder.get_children():
			if node is BreakableWall:
				node.destroyed.connect()
		
		completion_timer.wait_time = time

func _start_level() -> void:
	
	_check_win_condition_completion()
	
	if timed:
		completion_timer.start()

func try_finish_level() -> bool:
	if condition_met:
		level_finished.emit()
		
		@warning_ignore("narrowing_conversion")
		time_bonus = completion_timer.time_left * 10
		
		# maybe do some visual count up here? lerp seems right?
		# probably want to add these seperately for visual flair?
		level_score += time_bonus
		
		level_score += completion_bonus
		
		
		return true
	
	return false

func _on_brick_destroyed():
	bricks_destroyed += 1
	

func _check_win_condition_completion() -> float:
	var completion: float = 0
	match win_condition:
		WIN_CONDITION.None:
			completion = 1
		WIN_CONDITION.Brick_percentage:
			completion = (100.0 * bricks_destroyed / bricks_in_level) / brick_percentage
		WIN_CONDITION.Brick_num:
			completion = float(bricks_destroyed) / brick_num
		WIN_CONDITION.Trigger_percentage:
			completion = (100.0 * triggers_activated / triggers_in_level) / trigger_percentage
		WIN_CONDITION.Trigger_num:
			completion = float(triggers_activated) / trigger_num
	
	if completion >= 1:
		complete_win_condition(completion)
	
	return completion

func complete_win_condition(completion: float) -> void:
	condition_met.emit()
	@warning_ignore("narrowing_conversion")
	completion_bonus = maxi(100, (completion - 1) * 1000)

#region Get children of holder nodes
func get_breakable_bricks(parent: Node = breakable_bricks_holder) -> int:
	return get_children_of_type(parent, BreakableWall)

func get_triggers(parent: Node = trigger_holder) -> int:
	return get_children_of_type(parent, Area3D) # placeholder for a custom trigger type with a visual indicator

func get_children_of_type(parent: Node, type: Variant) -> int:
	var num: int = 0
	if !parent:
		parent = self
	for node in parent.get_children():
		if is_instance_of(node, type):
			num += 1
	return num
#endregion

# super expensive calc, only do this manually
func get_aabb():
	#important for automatic positioning of nodes if seemless transitions are required
	pass

# Concept copied from Phantom Camera source code
func _validate_property(property: Dictionary) -> void:
	if !timed:
		match property.name:
			"time", \
			"stop_timer_on_win":
				property.usage = PROPERTY_USAGE_NO_EDITOR
	
	match win_condition:
		WIN_CONDITION.None:
			match property.name:
				"brick_percentage", \
				"brick_num", \
				"trigger_percentage", \
				"trigger_num":
					property.usage = PROPERTY_USAGE_NO_EDITOR
		WIN_CONDITION.Brick_num:
			match property.name:
				"brick_percentage", \
				#"brick_num", \
				"trigger_percentage", \
				"trigger_num":
					property.usage = PROPERTY_USAGE_NO_EDITOR
		WIN_CONDITION.Brick_percentage:
			match property.name:
				#"brick_percentage", \
				"brick_num", \
				"trigger_percentage", \
				"trigger_num":
					property.usage = PROPERTY_USAGE_NO_EDITOR
		WIN_CONDITION.Trigger_percentage:
			match property.name:
				"brick_percentage", \
				"brick_num", \
				#"trigger_percentage", \
				"trigger_num":
					property.usage = PROPERTY_USAGE_NO_EDITOR
		WIN_CONDITION.Trigger_num:
			match property.name:
				"brick_percentage", \
				"brick_num", \
				"trigger_percentage":
				#"trigger_num":
					property.usage = PROPERTY_USAGE_NO_EDITOR
