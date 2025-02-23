extends Node
# autoload Utils

enum COLLISION_LAYERS {
	Balls = 1 << 0, 			# 0001
	Solid_Walls = 1 << 1, 		# 0010
	Triggers = 1 << 2,			# 0100
}

class Conditions:
	
	static func breakable_brick(brick: Node) -> bool:
		if brick is BaseBrick:
			if brick.is_breakable:
				return true
		
		return false
	
	static func level_trigger(trigger: Node) -> bool:
		if trigger is LevelTrigger:
			return true
		
		return false
	
	static func level(node: Node) -> bool:
		if node is Level:
			return true
		
		return false

static func get_children_of_type(p_parent: Node, condition: Callable, children: Array[Node] = []) -> Array[Node]:
	for node: Node in p_parent.get_children():
		if node.get_child_count() > 0:
			get_children_of_type(node, condition, children)
		
		if condition.call(node):
			children.append(node)
	
	return children
