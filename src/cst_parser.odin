package tome

import "core:mem"
import "core:strings"

CST_Parser :: struct {
	tokenizer:  Tokenizer,
	allocator:  mem.Allocator,
	curr_token: Token,
}

advance_cst_token :: proc(p: ^CST_Parser) {
	p.curr_token = get_token(&p.tokenizer)
}

is_trivia :: proc(kind: Token_Kind) -> bool {
	return kind == .Whitespace || kind == .Newline || kind == .Comment
}

parse_cst_trivia :: proc(p: ^CST_Parser, parent: ^CST_Node) {
	for is_trivia(p.curr_token.kind) {
		child := new_cst_node(.Trivia, p.allocator)
		child.token = p.curr_token
		child.value_string = get_span_value(&p.tokenizer, p.curr_token)
		add_child(parent, child)
		advance_cst_token(p)
	}
}

consume_leaf :: proc(p: ^CST_Parser, kind: CST_Node_Kind, parent: ^CST_Node) -> ^CST_Node {
	child := new_cst_node(kind, p.allocator)
	child.token = p.curr_token
	child.value_string = get_span_value(&p.tokenizer, p.curr_token)
	add_child(parent, child)
	advance_cst_token(p)
	return child
}

parse_cst_value :: proc(p: ^CST_Parser, parent: ^CST_Node) {
	parse_cst_trivia(p, parent)
	
	if p.curr_token.kind == .String {
		consume_leaf(p, .String_Literal, parent)
	} else if p.curr_token.kind == .Integer {
		consume_leaf(p, .Integer_Literal, parent)
	} else if p.curr_token.kind == .Float {
		consume_leaf(p, .Float_Literal, parent)
	} else if p.curr_token.kind == .True || p.curr_token.kind == .False {
		consume_leaf(p, .Boolean_Literal, parent)
	} else if p.curr_token.kind == .Open_Brace {
		parse_cst_object(p, parent)
	} else if p.curr_token.kind == .Open_Bracket {
		parse_cst_array(p, parent)
	}
	
	parse_cst_trivia(p, parent)
}

parse_cst_array :: proc(p: ^CST_Parser, parent: ^CST_Node) {
	array_node := new_cst_node(.Array, p.allocator)
	add_child(parent, array_node)

	// Consume [
	consume_leaf(p, .Punctuation, array_node)
	
	for p.curr_token.kind != .EOF && p.curr_token.kind != .Close_Bracket {
		parse_cst_trivia(p, array_node)
		
		if p.curr_token.kind == .Close_Bracket {
			break
		}
		
		if p.curr_token.kind == .Comma {
			consume_leaf(p, .Punctuation, array_node)
		} else {
			parse_cst_value(p, array_node)
		}
	}
	
	parse_cst_trivia(p, array_node)
	
	if p.curr_token.kind == .Close_Bracket {
		consume_leaf(p, .Punctuation, array_node)
	}
}

parse_cst_object :: proc(p: ^CST_Parser, parent: ^CST_Node) {
	obj_node := new_cst_node(.Object, p.allocator)
	add_child(parent, obj_node)

	// Consume {
	consume_leaf(p, .Punctuation, obj_node)
	
	for p.curr_token.kind != .EOF && p.curr_token.kind != .Close_Brace {
		parse_cst_trivia(p, obj_node)
		
		if p.curr_token.kind == .Close_Brace {
			break
		}
		
		if p.curr_token.kind == .Comma {
			consume_leaf(p, .Punctuation, obj_node)
		} else if p.curr_token.kind == .Ident {
			parse_cst_key_value(p, obj_node)
		} else {
			// fallback advance to avoid infinite loop
			consume_leaf(p, .Punctuation, obj_node)
		}
	}
	
	parse_cst_trivia(p, obj_node)
	
	if p.curr_token.kind == .Close_Brace {
		consume_leaf(p, .Punctuation, obj_node)
	}
}

parse_cst_key_value :: proc(p: ^CST_Parser, parent: ^CST_Node) {
	kv_node := new_cst_node(.Key_Value, p.allocator)
	add_child(parent, kv_node)
	
	// Identifier
	consume_leaf(p, .Identifier, kv_node)
	parse_cst_trivia(p, kv_node)
	
	// Equal
	if p.curr_token.kind == .Equal {
		consume_leaf(p, .Punctuation, kv_node)
		parse_cst_trivia(p, kv_node)
		
		// Value
		parse_cst_value(p, kv_node)
	}
}

parse_cst :: proc(input: string, allocator := context.allocator) -> ^CST_Node {
	p := CST_Parser {
		tokenizer = create_tokenizer(input),
		allocator = allocator,
	}
	p.tokenizer.preserve_trivia = true
	advance_cst_token(&p)

	file_node := new_cst_node(.File, allocator)
	
	for p.curr_token.kind != .EOF {
		parse_cst_trivia(&p, file_node)
		
		if p.curr_token.kind == .EOF {
			break
		}
		
		if p.curr_token.kind == .Ident {
			parse_cst_key_value(&p, file_node)
		} else if p.curr_token.kind == .Comma {
			consume_leaf(&p, .Punctuation, file_node)
		} else {
			consume_leaf(&p, .Punctuation, file_node)
		}
	}
	
	return file_node
}