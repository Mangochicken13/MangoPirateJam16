extends Node

static func get_children_of_type(parent: Node, type: Variant) -> int:
	var num: int = 0
	if !parent:
		push_error("No node provided")
		return 0
	for node: Node in parent.get_children():
		if node.get_child_count() > 0:
			num += get_children_of_type(node, type)
		if is_instance_of(node, type):
			num += 1
	return num
