package tome

CST_Node_Kind :: enum {
	File,
	Object,
	Array,
	Key_Value,
	Identifier,
	String_Literal,
	Integer_Literal,
	Float_Literal,
	Boolean_Literal,
	Trivia,       // For Whitespace, Newlines, and Comments
	Punctuation,  // Equals, Commas, Brackets, Braces
}

CST_Node :: struct {
	kind:         CST_Node_Kind,
	token:        Token, // If it's a leaf node/trivia, or for span
	children:     [dynamic]^CST_Node,
	value_string: string, // Store the raw string for serialization
}

new_cst_node :: proc(kind: CST_Node_Kind, allocator := context.allocator) -> ^CST_Node {
	node := new(CST_Node, allocator)
	node.kind = kind
	node.children = make([dynamic]^CST_Node, allocator)
	return node
}

add_child :: proc(parent: ^CST_Node, child: ^CST_Node) {
	append(&parent.children, child)
}
