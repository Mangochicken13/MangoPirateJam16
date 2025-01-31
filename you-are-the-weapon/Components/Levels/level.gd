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

const GET_TO_THE_EXIT = "Get Going!"
const _BREAK_BRICK_NUM = "Break {0} Bricks!"
const _BREAK_BRICK_PERCENTAGE = "Break {0}% of Bricks!"
const _ACTIVATE_TRIGGER_NUM = "Enter {0} of Triggers!"
const _ACTIVATE_TRIGGER_PERCENTAGE = "Enter {0}% of Triggers!"

#region Export vars

@export var win_condition: WIN_CONDITION:
	set(condition):
		win_condition = condition
		notify_property_list_changed()

@export_range(0, 100, 1, "suffix:%") var brick_percentage: int = 60
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

@export var _brick_num: int = 0

@export_range(0, 100, 1, "suffix:%") var trigger_percentage: int = 100
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
@export_custom(PROPERTY_HINT_NONE, "suffix:seconds") var time: float = 120

@export var score_multiplier: float = 1

@export_category("References")
@export var exit_area: Area3D
@export var entrance_area: Area3D
@export var door: StaticBody3D

@export var trigger_holder: Node
@export var breakable_bricks_holder: Node
@export var solid_walls_holder: Node

@export var completion_timer: Timer

@export var boundary: AABB = AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))
@export var update_boundary: bool:
	set(value):
		boundary = get_aabb(self, false, self.transform)
		update_boundary = value

#endregion

var win_condition_met: bool = false
var level_complete: bool = false
var completion: float = 0

var bricks_in_level: int = 0
var bricks_destroyed: int = 0

var triggers_in_level: int = 0
var triggers_activated: int = 0

var level_score: int = 0
var time_bonus: int = 0
var completion_bonus: int = 0


func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		if exit_area:
			exit_area.body_entered.connect(try_finish_level)
		else:
			push_error("No exit for level ", get_tree().current_scene.scene_file_path.get_file().get_basename())
		
		if entrance_area:
			entrance_area.body_entered.connect(_on_level_entered)
		
		bricks_in_level = get_breakable_bricks()
		triggers_in_level = get_triggers()
		print(get_breakable_bricks())
		
		_recursive_connect_bricks()
		
		for i in trigger_holder.get_child_count():
			var child = trigger_holder.get_child(i)
			if child is LevelTrigger:
				child.triggered.connect(_on_trigger_activated)
		
		completion_timer.wait_time = time

#func _process(delta: float) -> void:
	#if Engine.is_editor_hint():
		#var debug_draw = DebugDraw3D as Variant
		#debug_draw.call("draw_aabb", boundary, Color.DARK_ORANGE)
	#pass

func _recursive_connect_bricks(p_node: Node = breakable_bricks_holder):
	for node in p_node.get_children():
		if node.get_child_count() > 0: 
			_recursive_connect_bricks(node)
		if node is BreakableWall:
			node.destroyed.connect(_on_brick_destroyed)

func _start_level() -> void:
	
	_check_win_condition_completion()
	
	if timed:
		completion_timer.start()

func _on_level_entered(_body: Node3D):
	SignalBus.level_entered.emit(self)
	entrance_area.body_entered.disconnect(_on_level_entered)
	_start_level()

func try_finish_level(_body: Node3D) -> bool:
	if win_condition_met and not level_complete:
		level_complete = true
		
		@warning_ignore("narrowing_conversion")
		completion_bonus = maxi(100, (completion - 1) * 500)
		
		@warning_ignore("narrowing_conversion")
		time_bonus = completion_timer.time_left * 10
		
		# maybe do some visual count up here? lerp seems right?
		# probably want to add these seperately for visual flair?
		level_score += time_bonus
		
		level_score += completion_bonus
		
		SignalBus.level_exited.emit(self)
		
		return true
	
	return false

func _on_brick_destroyed():
	bricks_destroyed += 1
	level_score += 20
	_check_win_condition_completion()

func _on_trigger_activated():
	triggers_activated += 1
	level_score += 50
	_check_win_condition_completion()

func _check_win_condition_completion() -> float:
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
	
	if completion >= 1 and !win_condition_met:
		complete_win_condition()
	
	return completion

func complete_win_condition() -> void:
	SignalBus.level_win_condition_met.emit(self)
	win_condition_met = true
	if timed and stop_timer_on_win and not completion_timer.paused:
		completion_timer.paused = true
	# super temporary code, want this to be on the door node
	if door:
		var tween = get_tree().create_tween()
		tween.tween_property(door, "position", door.position + Vector3(0, 0, -3), 1)
		tween.tween_property(door, "position", door.position + Vector3(0, -10, -3), 1.5)
		tween.tween_callback(door.queue_free)

func objective_text(p_win_condition: int = -1) -> String:
	var local_win_condition: int
	if p_win_condition == -1:
		local_win_condition = win_condition
	else:
		local_win_condition = p_win_condition
	
	match local_win_condition:
		Level.WIN_CONDITION.None:
			return GET_TO_THE_EXIT
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

#region Get children of holder nodes

func get_breakable_bricks(parent: Node = breakable_bricks_holder) -> int:
	return get_children_of_type(parent, BreakableWall)

func get_triggers(parent: Node = trigger_holder) -> int:
	return get_children_of_type(parent, LevelTrigger)

func get_children_of_type(parent: Node, type: Variant) -> int:
	var num: int = 0
	if !parent:
		parent = self
	for node in parent.get_children():
		if node.get_child_count() > 0:
			num += get_children_of_type(node, type)
		if is_instance_of(node, type):
			num += 1
	return num

#endregion

#region AABB calculator

# super expensive calc, only do this manually
# Code adapted from the godot source code: https://github.com/godotengine/godot/blob/master/editor/plugins/node_3d_editor_plugin.cpp#L4475
func get_aabb(p_parent: Node3D, p_omit_top_level: bool, p_bounds_orientation: Transform3D):
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
				shape_bounds.size = (2 * Vector3(x.radius, x.radius, x.radius))
		
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
		
		#if typeof(p_parent.get_child(i)) == typeof(Node):
			#var child_as_node: Node = p_parent.get_child(i)
			#for j in child_as_node.get_child_count():
				#child_as_node
	
	print(p_parent.name)
	print(bounds)
	return bounds;
	
	#important for automatic positioning of nodes if seemless transitions are required

# Use this to make the check propagate through Node children trees
#func _propagate_get_aabb()

#endregion

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
				"brick_num":
					property.usage = PROPERTY_USAGE_NO_INSTANCE_STATE + PROPERTY_USAGE_EDITOR
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
				"trigger_num":
					property.usage = PROPERTY_USAGE_NO_INSTANCE_STATE + PROPERTY_USAGE_EDITOR
	
	match property.name:
		"_brick_num", \
		"_trigger_num":
			property.usage = PROPERTY_USAGE_NO_EDITOR
