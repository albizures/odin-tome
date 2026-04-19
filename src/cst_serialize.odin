package tome

import "core:mem"
import "core:strings"

serialize_cst :: proc(node: ^CST_Node) -> string {
	builder := strings.builder_make()
	serialize_cst_node(node, &builder)
	return strings.to_string(builder)
}

serialize_cst_node :: proc(node: ^CST_Node, builder: ^strings.Builder) {
	if node == nil {
		return
	}
	
	if len(node.children) == 0 {
		strings.write_string(builder, node.value_string)
	} else {
		for child in node.children {
			serialize_cst_node(child, builder)
		}
	}
}