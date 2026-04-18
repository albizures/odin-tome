package st_src

import "core:mem"
import "core:slice"

Visit_Result :: enum {
	Done,
	Parent,
	Child,
}

Visitor_Test :: union {
	Kind_Test,
	Node_Test,
}

Visitor_Kind :: enum {
	Pre_Order,
}

Visitor_State :: struct {
	parent: Parent,
	index:  int,
}

Visitor :: struct {
	allocator: mem.Allocator,
	tree:      Tree,
	path:      [dynamic]Visitor_State,
	level:     int,
	kind:      Visitor_Kind,
	test:      Visitor_Test,
	reverse:   bool,
}

create_visitor :: proc {
	create_visitor_simple,
	create_visitor_with_test,
}

create_visitor_simple :: proc(
	tree: Tree,
	kind: Visitor_Kind,
	reverse := false,
	allocator := context.allocator,
) -> Visitor {
	v := Visitor {
		allocator = allocator,
		tree      = tree,
		path      = make([dynamic]Visitor_State, allocator),
		level     = 0,
		kind      = kind,
		reverse   = reverse,
	}
	return v
}

create_visitor_with_test :: proc(
	tree: Tree,
	test: Visitor_Test,
	reverse := false,
	allocator := context.allocator,
) -> Visitor {
	v := create_visitor_simple(tree, .Pre_Order, reverse, allocator)
	v.test = test
	return v
}

destroy_visitor :: proc(v: Visitor) {
	delete(v.path)
}

next :: proc(v: ^Visitor) -> (node: Node, type: Visit_Result) {
	// looping in case the test fails and we need to skip nodes
	for {
		switch v.kind {
		case .Pre_Order:
			node, type = next_pre_order(v)
		}

		if type == .Done {
			return
		}

		if v.test != nil {
			match := false
			switch test in v.test {
			case Kind_Test:
				match = is(node, test)
			case Node_Test:
				parent_node: Node
				idx: int
				// Determine parent and index for Node_Test
				// If we just appended to path (Parent), it's at len-2
				// If we didn't (Node), it's at len-1
				// Root has len=1 and level=0 right after being returned
				if len(v.path) == 1 && v.level == 0 {
					parent_node = to_node(v.tree.root)
					idx = 0
				} else {
					state_idx := len(v.path) - 1
					// If the node we just visited was a parent, we pushed a new state.
					if type == .Parent {
						state_idx -= 1
					}

					if state_idx >= 0 {
						parent_node = to_node(v.path[state_idx].parent)
						idx = v.path[state_idx].index - (v.reverse ? -1 : 1)
					}
				}
				match = is(node, test, idx, parent_node)
			}

			if !match {
				continue
			}
		}

		return
	}
}


next_pre_order :: proc(v: ^Visitor) -> (node: Node, type: Visit_Result) {
	if len(v.path) == 0 {
		if v.level == 0 {
			append(
				&v.path,
				Visitor_State {
					parent = v.tree.root,
					index = v.reverse ? len(v.tree.root.children) - 1 : 0,
				},
			)
			type = .Parent
			node = to_node(v.tree.root)
			return
		}

		type = .Done
		return
	}

	state := &v.path[len(v.path) - 1]

	if state.index >= len(state.parent.children) || (v.reverse && state.index < 0) {
		// we need to backtrack
		pop(&v.path)
		v.level -= 1
		if len(v.path) == 0 {
			type = .Done
			return
		}

		return next_pre_order(v)
	}

	// check if the current node has children
	current := state.parent.children[state.index]
	state.index += v.reverse ? -1 : 1

	switch cur in current {
	case Parent:
		append(&v.path, Visitor_State{parent = cur, index = v.reverse ? len(cur.children) - 1 : 0})
		v.level += 1
		type = .Parent
		node = to_node(current)
		return
	case Node:
		type = .Child
		node = to_node(current)
		return
	}

	return
}

to_node :: proc(node: Child) -> Node {
	switch n in node {
	case Parent:
		return n
	case Node:
		return n
	}

	panic("Invalid state")
}
