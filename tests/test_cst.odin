package tome_tests

import tome "../src"
import "core:log"
import "core:testing"

@(test)
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

@(test)
test_cst_roundtrip :: proc(t: ^testing.T) {
	input := `
# This is a comment
port = 8080

server = {
	host = "localhost",
	active = true
}

# Array test
ports = [
	80,
	443
]
`

	cst := tome.parse_cst(input)
	defer tome.free_cst_node(cst)

	output := tome.serialize_cst(cst)
	defer delete(output)

	testing.expect_value(t, output, input)
}

@(test)
test_cst_mutate :: proc(t: ^testing.T) {
	input := `
port = 8080 # default port
host = "localhost"
`

	cst := tome.parse_cst(input)
	defer tome.free_cst_node(cst)

	port_node := tome.cst_find_node_by_key(cst, "port")
	testing.expect(t, port_node != nil, "port node should be found")

	tome.cst_update_value(port_node, "9000")

	expected := `
port = 9000 # default port
host = "localhost"
`
	output := tome.serialize_cst(cst)
	defer delete(output)
	testing.expect_value(t, output, expected)
}
