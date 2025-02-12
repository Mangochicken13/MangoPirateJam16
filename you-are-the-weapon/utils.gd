extends Node
# autoload Utils

enum COLLISION_LAYERS {
	Balls = 1 << 0, 			# 0001
	Solid_Walls = 1 << 1, 		# 0010
	Triggers = 1 << 2,			# 0100
}

static func get_children_of_type(p_parent: Node, p_type: Variant) -> int:
	var num: int = 0
	if !p_parent:
		push_error("No node provided")
		return 0
	for node: Node in p_parent.get_children():
		if node.get_child_count() > 0:
			num += get_children_of_type(node, p_type)
		if is_instance_of(node, p_type):
			num += 1
	return num
