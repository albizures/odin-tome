package st_test

import st "../src"
import "core:mem"
import "core:testing"

@(test)
test_visitor_pre_order :: proc(t: ^testing.T) {
	root_node := st.Node {
		kind = 1,
	}
	child_a := st.Node {
		kind = 2,
	}
	child_b_node := st.Node {
		kind = 3,
	}
	child_c := st.Node {
		kind = 4,
	}

	child_b := st.Parent {
		node     = child_b_node,
		children = make([dynamic]st.Child, context.allocator),
	}
	append(&child_b.children, st.Child(child_c))

	root := st.Parent {
		node     = root_node,
		children = make([dynamic]st.Child, context.allocator),
	}
	append(&root.children, st.Child(child_a))
	append(&root.children, st.Child(child_b))

	tree := st.Tree {
		allocator = context.allocator,
		root      = root,
	}

	defer {
		delete(root.children)
		delete(child_b.children)
	}

	visitor := st.create_visitor(tree, st.Visitor_Kind.Pre_Order)
	defer st.destroy_visitor(visitor)

	// Pre-order traversal visits parent, then children.
	// The root itself IS visited, so the first node should be 1.

	n: st.Node
	type: st.Visit_Result

	n, type = st.next(&visitor)
	testing.expect(t, type == .Parent)
	testing.expect_value(t, n.kind, 1) // root

	n, type = st.next(&visitor)
	testing.expect(t, type == .Child)
	testing.expect_value(t, n.kind, 2) // child_a

	n, type = st.next(&visitor)
	testing.expect(t, type == .Parent)
	testing.expect_value(t, n.kind, 3) // child_b's node

	n, type = st.next(&visitor)
	testing.expect(t, type == .Child)
	testing.expect_value(t, n.kind, 4) // child_c

	n, type = st.next(&visitor)
	testing.expect(t, type == .Done)
}

@(test)
test_visitor_with_test :: proc(t: ^testing.T) {
	root_node := st.Node {
		kind = 1,
	}
	child_a := st.Node {
		kind = 2,
	}

	root := st.Parent {
		node     = root_node,
		children = make([dynamic]st.Child, context.allocator),
	}
	append(&root.children, st.Child(child_a))

	tree := st.Tree {
		allocator = context.allocator,
		root      = root,
	}

	defer delete(root.children)

	kind_test := st.Kind_Test{0, 2}
	visitor := st.create_visitor(tree, kind_test)
	defer st.destroy_visitor(visitor)

	testing.expect(t, visitor.test == kind_test, "Visitor should have the test property set")

	n: st.Node
	type: st.Visit_Result

	n, type = st.next(&visitor)
	testing.expect(t, type == .Child)
	testing.expect_value(t, n.kind, 2)

	n, type = st.next(&visitor)
	testing.expect(t, type == .Done)
}


@(test)
test_create_reverse_visitor :: proc(t: ^testing.T) {
	root_node := st.Node {
		kind = 1,
	}
	child_a := st.Node {
		kind = 2,
	}
	child_b_node := st.Node {
		kind = 3,
	}
	child_c := st.Node {
		kind = 4,
	}

	child_b := st.Parent {
		node     = child_b_node,
		children = make([dynamic]st.Child, context.allocator),
	}
	append(&child_b.children, st.Child(child_c))

	root := st.Parent {
		node     = root_node,
		children = make([dynamic]st.Child, context.allocator),
	}
	append(&root.children, st.Child(child_a))
	append(&root.children, st.Child(child_b))

	tree := st.Tree {
		allocator = context.allocator,
		root      = root,
	}

	defer {
		delete(root.children)
		delete(child_b.children)
	}

	visitor := st.create_visitor(tree, st.Visitor_Kind.Pre_Order, reverse = true)
	defer st.destroy_visitor(visitor)

	n: st.Node
	type: st.Visit_Result

	n, type = st.next(&visitor)
	testing.expect(t, type == .Parent)
	testing.expect_value(t, n.kind, 1) // root

	n, type = st.next(&visitor)
	testing.expect(t, type == .Parent)
	testing.expect_value(t, n.kind, 3) // child_b

	n, type = st.next(&visitor)
	testing.expect(t, type == .Child)
	testing.expect_value(t, n.kind, 4) // child_c

	n, type = st.next(&visitor)
	testing.expect(t, type == .Child)
	testing.expect_value(t, n.kind, 2) // child_a

	n, type = st.next(&visitor)
	testing.expect(t, type == .Done)
}
