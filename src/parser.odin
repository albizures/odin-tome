package tome

import "core:log"
import "core:mem"
import "core:strconv"

Nil :: distinct rawptr
Integer :: i64
Float :: f64
Bool :: bool
String :: string
Array :: distinct [dynamic]Value
Object :: distinct map[string]Value
Null :: distinct rawptr

Value :: union {
	Integer,
	Float,
	Bool,
	String,
	Array,
	Object,
	Nil,
}


Tome_Error :: enum {
	Invalid_Token,
	Invalid_Ident,
	Invalid_Value,
	Missing_Ident,
	Invalid_Int,
	Invalid_Float,
	Invalid_Bool,
}

Parser :: struct {
	tokenizer:  Tokenizer,
	allocator:  mem.Allocator,
	errors:     [dynamic]Tome_Error,
	result:     ^Object,
	curr_token: Token,
}

advance_token :: proc(parser: ^Parser) {
	parser.curr_token = get_token(&parser.tokenizer)
}

parse :: proc(
	input: string,
	allocator := context.allocator,
) -> (
	result: Object,
	errors: []Tome_Error,
) {
	parser := Parser {
		tokenizer = make_tokenizer(input),
		allocator = allocator,
		errors    = make([dynamic]Tome_Error, allocator),
	}


	return parse_next(&parser), parser.errors[:]
}

parse_next :: proc(p: ^Parser) -> (result: Object) {
	result = make(Object, p.allocator)
	loop: for {
		advance_token(p)
		#partial switch p.curr_token.kind {
		case .Invalid:
			append(&p.errors, Tome_Error.Invalid_Token)
		case .Comment:
			continue
		case .Ident:
			parse_ident(p, &result)
		case .EOF:
			break loop
		case:
			append(&p.errors, Tome_Error.Invalid_Token)
		}
	}

	return
}

parse_ident :: proc(p: ^Parser, result: ^Object) {
	assert(p.curr_token.kind == .Ident, "Invalid call to parse_ident")
	// let's check if the identifier is valid
	if p.curr_token.span.start - p.curr_token.span.end >= 0 {
		append(&p.errors, Tome_Error.Invalid_Ident)
		return
	}

	name := get_span_value(p.tokenizer, p.curr_token)
	advance_token(p)

	// expects an equal after the identifier
	if p.curr_token.kind != .Equal {
		append(&p.errors, Tome_Error.Invalid_Token)
		// let's continue parsing
	} else {
		advance_token(p)
	}

	result[name] = parse_value(p)
}

parse_value :: proc(p: ^Parser) -> Value {
	str := get_current_value(p)
	#partial switch p.curr_token.kind {
	case .String:
		return parse_string(p, str)
	case .Integer:
		return parse_int(p, str)
	case .Float:
		return parse_float(p, str)
	case .True, .False:
		return parse_bool(p, str)
	case .Nil:
		value := Nil{}
		return value
	case:
		append(&p.errors, Tome_Error.Invalid_Value)
		value := Nil{}
		return value
	}
}

parse_string :: proc(parser: ^Parser, value: string) -> string {
	return unquote(value)
}

unquote :: proc(value: string) -> string {
	// for now we don't check the string
	return value[1:len(value) - 1]
}

parse_int :: proc(parser: ^Parser, value: string) -> i64 {
	number, ok := strconv.parse_i64(value)

	if !ok {
		append(&parser.errors, Tome_Error.Invalid_Int)
	}

	return number
}

parse_float :: proc(parser: ^Parser, value: string) -> f64 {
	number, ok := strconv.parse_f64(value)

	if !ok {
		append(&parser.errors, Tome_Error.Invalid_Float)
	}

	return number
}

parse_bool :: proc(parser: ^Parser, value: string) -> bool {
	if value == "true" {
		return true
	} else if value == "false" {
		return false
	}

	append(&parser.errors, Tome_Error.Invalid_Bool)
	return false
}


get_current_value :: proc(p: ^Parser) -> string {
	return get_span_value(p.tokenizer, p.curr_token)
}
