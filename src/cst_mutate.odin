package tome_src

import "core:mem"
import "core:strings"

cst_find_node_by_key :: proc(root: ^CST_Node, key: string) -> ^CST_Node {
	if root == nil {
		return nil
	}
	
	if root.kind == .Key_Value {
		// First child is the identifier usually (ignoring trivia)
		for child in root.children {
			if child.kind == .Identifier {
				if child.value_string == key {
					return root
				}
				break
			}
		}
	}
	
	for child in root.children {
		found := cst_find_node_by_key(child, key)
		if found != nil {
			return found
		}
	}
	
	return nil
}

cst_update_value :: proc(node: ^CST_Node, new_literal: string) {
	if node == nil || node.kind != .Key_Value {
		return
	}
	
	// Find the value node
	for i := 0; i < len(node.children); i += 1 {
		child := node.children[i]
		if child.kind == .String_Literal || 
		   child.kind == .Integer_Literal || 
		   child.kind == .Float_Literal || 
		   child.kind == .Boolean_Literal {
			child.value_string = new_literal
			return
		}
	}
}
