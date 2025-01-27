@tool
extends Node3D
class_name Level


enum WIN_CONDITION {
	None,
	Brick_percentage,
	Brick_num,
	Triggers,
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

## If the selected win condition has a time to complete it in
@export var timed: bool = false:
	set(value):
		timed = value
		notify_property_list_changed()
@export var stop_timer_on_win: bool = false
@export var time: float = 120


@export var exit_trigger: Area3D
@export var boundary: AABB

func _ready() -> void:
	if exit_trigger:
		exit_trigger.body_entered.connect(try_finish_level)

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
