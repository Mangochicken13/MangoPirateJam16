@tool
extends Node3D
class_name Level


enum WIN_CONDITION { ## The condition to meet for the exit to enable
	None, ## No condition
	Brick_percentage, ## Break [member brick_percentage] of bricks in the level
	Brick_num, ## Break [member brick_num] bricks in the level (must be less than or equal to the total number of bricks)
	Triggers, ## Enter all of the areas in [member triggers]
}

@export var win_condition: WIN_CONDITION:
	set(condition):
		win_condition = condition
		notify_property_list_changed()
@export_range(0, 100, 1) var brick_percentage: int = 60
@export var brick_num: int:
	set(num):
		# validate this against the number of bricks in the level
		brick_num = num

@export var triggers: Array[Node3D] = []

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


@export var exit_trigger: Area3D
@export var boundary: AABB

func _ready() -> void:
	if exit_trigger:
		exit_trigger.body_entered.connect(try_finish_level)
	else:
		push_error("No exit trigger selected")

func try_finish_level():
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
				"triggers":
					property.usage = PROPERTY_USAGE_NO_EDITOR
		WIN_CONDITION.Brick_num:
			match property.name:
				"brick_percentage", \
				"triggers":
					property.usage = PROPERTY_USAGE_NO_EDITOR
		WIN_CONDITION.Brick_percentage:
			match property.name:
				"brick_num", \
				"triggers":
					property.usage = PROPERTY_USAGE_NO_EDITOR
		WIN_CONDITION.Triggers:
			match property.name:
				"brick_num", \
				"brick_percentage":
					property.usage = PROPERTY_USAGE_NO_EDITOR
