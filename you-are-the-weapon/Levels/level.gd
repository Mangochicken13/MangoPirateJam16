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

const _GET_TO_THE_EXIT: String = "Get Going!"
const _BREAK_BRICK_NUM: String = "Break {0} Bricks!"
const _BREAK_BRICK_PERCENTAGE: String = "Break {0}% of Bricks!"
const _ACTIVATE_TRIGGER_NUM: String = "Enter {0} of Triggers!"
const _ACTIVATE_TRIGGER_PERCENTAGE: String = "Enter {0}% of Triggers!"

# This function is up here as it's relevant to the constants
func objective_text(p_win_condition: int = -1) -> String:
	var local_win_condition: int
	if p_win_condition == -1:
		local_win_condition = win_condition
	else:
		local_win_condition = p_win_condition
	
	match local_win_condition:
		Level.WIN_CONDITION.None:
			return _GET_TO_THE_EXIT
		Level.WIN_CONDITION.Brick_num:
			return _BREAK_BRICK_NUM.format([brick_num])
		Level.WIN_CONDITION.Brick_percentage:
			return _BREAK_BRICK_PERCENTAGE.format([brick_percentage])
		Level.WIN_CONDITION.Trigger_num:
			return _ACTIVATE_TRIGGER_NUM.format([trigger_num])
		Level.WIN_CONDITION.Trigger_percentage:
			return _ACTIVATE_TRIGGER_PERCENTAGE.format([trigger_percentage])
		_:
			return "error"

#region Export vars

@export var win_condition: WIN_CONDITION:
	set(condition):
		win_condition = condition
		notify_property_list_changed()

@export_range(0, 100, 1, "suffix:%") var brick_percentage: int = 60
## Cannot exceed the number of breakable bricks in the level
@export_range(0, 1000, 1, "or_greater") var brick_num: int:
	set(num):
		if Engine.is_editor_hint():
			bricks_in_level = get_breakable_bricks()
			if num > bricks_in_level:
				_brick_num = bricks_in_level
				#print("Variable \"Brick Num\" cannot exceed the number of bricks in the scene (%s)" % bricks_in_level)
				return
			_brick_num = num
	get():
		return _brick_num
## Backing property for [member brick_num]
@export var _brick_num: int = 0

@export_range(0, 100, 1, "suffix:%") var trigger_percentage: int = 100
## Cannot exceed the number of triggers in the level
@export_range(0, 255, 1, "or_greater") var trigger_num: int:
	set(num):
		if Engine.is_editor_hint():
			triggers_in_level = get_triggers()
			if num > triggers_in_level:
				_trigger_num = triggers_in_level
				#print("Variable \"Trugger Num\" cannot exceed the number of bricks in the scene (%s)" % triggers_in_level)
				return
			_trigger_num = num
	get():
		return _trigger_num
## Backing property for [member trigger_num]
@export var _trigger_num: int = 0

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
## Time in seconds for the level to be completed in
@export_custom(PROPERTY_HINT_NONE, "suffix:seconds") var time: float = 120

## A multiplier for the level score. 1 = 100%
## Use to give bonus score in difficult levels
@export var score_multiplier: float = 1

@export_category("References")
@export var entrance_area: Area3D
@export var exit_area: Area3D
@export var door: StaticBody3D

@export var trigger_holder: Node
@export var breakable_bricks_holder: Node
@export var solid_walls_holder: Node

@export var completion_timer: Timer

@export var boundary: AABB = AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))
@export_tool_button("Update Boundary") var update_boundary: Callable = _update_boundary

#endregion

## Has the win condition been completed. This does not account for if the timer is still going
var is_win_condition_met: bool = false
## If the player has completed and exited the level. Used to prevent adding extra points to the player score
var is_level_complete: bool = false
## Completion percentage. 1 = 100% complete. 
## Can exceed 1, and will reward extra points in levels that are timed and continue after reaching the win condition
var completion: float = 0

var bricks_in_level: int = 0
var bricks_destroyed: int = 0
var all_bricks_destroyed: bool = false

var triggers_in_level: int = 0
var triggers_activated: int = 0
var all_triggers_activated: bool = false

var level_score: int = 0
var time_bonus: int = 0
var completion_bonus: int = 0

const BRICK_SCORE: int = 20
const BRICK_BONUS_MULTIPLIER: int = 5
const TRIGGER_SCORE: int = 50
const TRIGGER_BONUS_MULTIPLIER: int = 20
const LEVEL_COMPLETE_BONUS: int = 100
const FULL_CLEAR_BONUS_SCORE: int = 300

#region Signals

signal level_entered(level: Level)
signal level_exited(level: Level)
signal level_win_condition_met(level: Level)
signal level_timer_timeout(level: Level)

#endregion

func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		if exit_area:
			exit_area.body_entered.connect(_on_try_exit_level)
		else:
			push_error("No exit for level ", scene_file_path.get_basename())
		
		if entrance_area:
			entrance_area.body_entered.connect(_on_level_entered)
		else:
			push_error("No entrance for level ", scene_file_path.get_basename())
		
		bricks_in_level = get_breakable_bricks()
		triggers_in_level = get_triggers()
		
		_recursive_connect_bricks()
		
		for i in trigger_holder.get_child_count():
			var child: Node = trigger_holder.get_child(i)
			if child is LevelTrigger:
				child.triggered.connect(_on_trigger_activated)
		
		if completion_timer:
			completion_timer.wait_time = time
			completion_timer.timeout.connect(_on_completion_timer_timeout)

func get_breakable_bricks(parent: Node = breakable_bricks_holder) -> int:
	return Utils.get_children_of_type(parent, BreakableWall)

func get_triggers(parent: Node = trigger_holder) -> int:
	return Utils.get_children_of_type(parent, LevelTrigger)

func _start_level() -> void:
	_check_win_condition_completion()
	
	if timed:
		completion_timer.start()

# TODO: Update this to use Bricks instead of BreakableWalls
func _recursive_connect_bricks(p_node: Node = breakable_bricks_holder) -> void:
	for i in p_node.get_child_count():
		var child: Node = p_node.get_child(i)
		if child.get_child_count() > 0: 
			_recursive_connect_bricks(child)
		if child is BreakableWall:
			child.destroyed.connect(_on_brick_destroyed)

func _check_win_condition_completion() -> void:
	match win_condition:
		WIN_CONDITION.None:
			completion = 1.0
			
		WIN_CONDITION.Brick_percentage:
			if brick_percentage == 0.0:
				print_debug("Brick percentage for % is 0, is this intended?" % scene_file_path.get_basename())
				completion = 1.0
			completion = (100.0 * bricks_destroyed / bricks_in_level) / brick_percentage
			
		WIN_CONDITION.Brick_num:
			if brick_num == 0:
				print_debug("Brick num for % is 0, is this intended?" % scene_file_path.get_basename())
				completion = 1.0
			completion = float(bricks_destroyed) / brick_num
			
		WIN_CONDITION.Trigger_percentage:
			if trigger_percentage == 0.0:
				print_debug("Trigger percentage for % is 0, is this intended?" % scene_file_path.get_basename())
				completion = 1.0
			completion = (100.0 * triggers_activated / triggers_in_level) / trigger_percentage
			
		WIN_CONDITION.Trigger_num:
			if trigger_num == 0:
				print_debug("Trigger num for % is 0, is this intended?" % scene_file_path.get_basename())
				completion = 1.0
			completion = float(triggers_activated) / trigger_num
	
	if completion >= 1 and !is_win_condition_met:
		complete_win_condition()

func complete_win_condition() -> void:
	if is_win_condition_met:
		return
	
	#SignalBus.level_win_condition_met.emit(self)
	level_win_condition_met.emit(self)
	
	is_win_condition_met = true
	if timed and stop_timer_on_win and not completion_timer.paused:
		completion_timer.paused = true
	
	# TODO: make unique door node that allows setting a movement action in editor
	if door:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(door, "position", door.position + Vector3(0, -10, 0), 1.5)
		tween.tween_callback(door.queue_free)


#region Signal Responses

func _on_try_exit_level(_body: Node3D) -> bool:
	if is_win_condition_met and not is_level_complete:
		is_level_complete = true
		
		# Bonus completion percentage with time to spare
		if timed and not stop_timer_on_win:
			@warning_ignore("narrowing_conversion")
			completion_bonus = maxi(LEVEL_COMPLETE_BONUS, (completion - 1) * 500)
		# Standard level completion bonus
		else:
			completion_bonus = LEVEL_COMPLETE_BONUS
		
		# Extra bonuses for 100% completion
		if all_bricks_destroyed:
			completion_bonus += bricks_in_level * BRICK_BONUS_MULTIPLIER
		
		if all_triggers_activated:
			completion_bonus += triggers_in_level * TRIGGER_BONUS_MULTIPLIER
		
		if all_bricks_destroyed and all_triggers_activated:
			completion_bonus += FULL_CLEAR_BONUS_SCORE
		
		# Time bonus
		if timed:
			@warning_ignore("narrowing_conversion")
			time_bonus = completion_timer.time_left * 10
		
		# maybe do some visual count up here? lerp seems right?
		# probably want to add these seperately for visual flair?
		level_score += time_bonus
		
		level_score += completion_bonus
		
		#SignalBus.level_exited.emit(self)
		level_exited.emit(self)
		
		return true
	
	return false

func _on_level_entered(_body: Node3D) -> void:
	#SignalBus.level_entered.emit(self)
	level_entered.emit(self)
	entrance_area.body_entered.disconnect(_on_level_entered)
	_start_level()

func _on_brick_destroyed() -> void:
	bricks_destroyed += 1
	level_score += BRICK_SCORE
	if bricks_destroyed == bricks_in_level and not bricks_in_level == 0:
		all_bricks_destroyed = true
	_check_win_condition_completion()

func _on_trigger_activated() -> void:
	triggers_activated += 1
	level_score += TRIGGER_SCORE
	if triggers_activated == triggers_in_level and not triggers_in_level == 0:
		all_triggers_activated = true
	_check_win_condition_completion()

func _on_completion_timer_timeout() -> void:
	level_timer_timeout.emit(self)

#endregion


#region AABB calculator

func _update_boundary() -> void:
	boundary = get_aabb(self, true, self.transform)

# super expensive calc, only do this manually
# Code adapted from the godot source code as of 4.3: https://github.com/godotengine/godot/blob/master/editor/plugins/node_3d_editor_plugin.cpp#L4475
func get_aabb(p_parent: Node3D, p_omit_top_level: bool, p_bounds_orientation: Transform3D) -> AABB:
	var bounds: AABB
	
	var bounds_orientation: Transform3D
	if (p_bounds_orientation):
		bounds_orientation = p_bounds_orientation;
	else:
		bounds_orientation = p_parent.get_global_transform();
	
	# meant for null pointers i think?
	if (!p_parent):
		return AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4));
	
	var xform_to_top_level_parent_space: Transform3D = bounds_orientation.affine_inverse() * p_parent.get_global_transform();
	
	var visual_instance: VisualInstance3D = p_parent as VisualInstance3D
	if (visual_instance):
		bounds = visual_instance.get_aabb();
	else:
		bounds = AABB();
	
	# adding collision shapes to the bounding box
	if p_parent is CollisionShape3D:
		var shape: Shape3D = p_parent.shape
		var shape_bounds: AABB = AABB()
		match shape:
			var box when box is BoxShape3D:
				shape_bounds.size = box.size
			var x when x is SphereShape3D:
				var radius: float = (x as SphereShape3D).radius
				shape_bounds.size = (2 * Vector3(radius, radius, radius))
		
		bounds = bounds.merge(AABB(p_parent.global_position - shape_bounds.size / 2, shape_bounds.size))
	
	bounds = xform_to_top_level_parent_space * bounds;
	
	for i in p_parent.get_child_count():
		#print(p_parent.get_child(i).name)
		var child: Node3D = p_parent.get_child(i) as Node3D;
		#print(child)
		if (child && !(p_omit_top_level && child.is_set_as_top_level())):
			# recursive function
			var child_bounds: AABB = get_aabb(child, p_omit_top_level, bounds_orientation);
			bounds = bounds.merge(child_bounds);
	
	#print(p_parent.name)
	#print(bounds)
	return bounds;
	
	#important for automatic positioning of nodes if seemless transitions are required

# Used to draw the bounding box of the level, including collision shapes
#func _process(delta: float) -> void:
	#if Engine.is_editor_hint():
		#var debug_draw = DebugDraw3D as Variant
		#debug_draw.call("draw_aabb", boundary, Color.DARK_ORANGE)
	#pass


#endregion


#region Editor Utils

# Concept copied from Phantom Camera source code
func _validate_property(property: Dictionary) -> void:
	
	# Turn off time vars if level isn't timed
	if !timed:
		match property.name:
			"time", \
			"stop_timer_on_win":
				property.usage = PROPERTY_USAGE_NO_EDITOR
	
	
	# Match shown variables to appropriate win condition
	# Commented variable names are shown in editor
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
	
	match property.name:
		# Disable wrappers from being saved into the .tscn
		"brick_num", \
		"trigger_num": # show variable but 
			property.usage += PROPERTY_USAGE_NO_INSTANCE_STATE
		# Hide backing properties in editor
		"_brick_num", \
		"_trigger_num":
			property.usage = PROPERTY_USAGE_NO_EDITOR

#endregion
