package tome_tests

import "core:testing"
import tome "../src"

@test
test_cst_node_creation :: proc(t: ^testing.T) {
	node := tome.new_cst_node(.Object)
	defer free(node)
	defer delete(node.children)
	
	testing.expect(t, node.kind == .Object)
	
	child := tome.new_cst_node(.Key_Value)
	defer free(child)
	defer delete(child.children)
	
	tome.add_child(node, child)
	
	testing.expect(t, len(node.children) == 1)
}
