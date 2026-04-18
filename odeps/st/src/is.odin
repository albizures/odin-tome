package st_src

// [offset, kind]
Kind_Test :: [2]Node_Kind
Node_Test :: #type proc(node: Node, index: int, parent: Node) -> bool

is :: proc {
	is_of_kind,
	is_of_one_kind,
	is_valid,
}

is_of_kind :: proc(node: Node, test: Kind_Test) -> bool {
	return node.kind == test[0] + test[1]
}

is_of_one_kind :: proc(node: Node, tests: []Kind_Test) -> bool {
	for test in tests {
		if is_of_kind(node, test) {
			return true
		}
	}

	return false
}

is_valid :: proc(node: Node, test: Node_Test, index: int, parent: Node) -> bool {
	return test(node, index, parent)
}
