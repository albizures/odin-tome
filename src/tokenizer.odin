package tome

import "core:fmt"
import "core:log"
import "core:unicode/utf8"
import tok "odeps:tokenizer"
import st "odeps:st"

Tokenizer :: struct {
	using tok: tok.Tokenizer,
	preserve_trivia: bool,
}

Token :: struct {
	using tok: tok.Token,
	kind:      Token_Kind,
}

Token_Kind :: enum {
	// special
	Invalid,
	EOF,
	Comment,
	Whitespace,
	Newline,

	// values
	False,
	True,
	Nil,
	Integer,
	Float,
	String,

	// syntax
	Equal,
	Comma,
	Open_Brace,
	Close_Brace,
	Open_Bracket,
	Close_Bracket,

	// other
	Ident,
}

create_tokenizer :: proc(input: string) -> Tokenizer {
	t := tok.create(input)
	return Tokenizer{tok = t}
}

is_letter :: proc(r: rune) -> bool {
	c := u8(r)
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
}

is_number :: proc(r: rune) -> bool {
	c := u8(r)
	return c >= '0' && c <= '9'
}

get_token :: proc(t: ^Tokenizer, loc := #caller_location) -> (token: Token) {
	switch t.current {
	case 'A' ..= 'Z', 'a' ..= 'z', '_':
		token.x = t.index
		consume_ident(t)
		token.y = t.index
		value := tok.get_value(t, token)

		if value == "true" {
			token.kind = .True
		} else if value == "false" {
			token.kind = .False
		} else if value == "nil" {
			token.kind = .Nil
		} else {
			token.kind = .Ident
		}
	case '0' ..= '9':
		token.x = t.index
		token.kind = consume_number(t)
		token.y = t.index
	case '"':
		token.x = t.index
		value := consume_string(t)
		token.y = t.index
		token.kind = .String
	case '\n', ' ', '\t', '\r':
		if t.preserve_trivia {
			token.x = t.index
			if t.current == '\n' || t.current == '\r' {
				token.kind = .Newline
				if t.current == '\r' {
					tok.advance(t)
					if t.current == '\n' {
						tok.advance(t)
					}
				} else {
					tok.advance(t)
				}
			} else {
				token.kind = .Whitespace
				for t.current == ' ' || t.current == '\t' {
					tok.advance(t)
				}
			}
			token.y = t.index
		} else {
			tok.advance(t)
			// maybe it would be better to ignore whitespace in the beginning
			return get_token(t)
		}
	case '#':
		token.x = t.index
		token.kind = .Comment
		consume_comment(t)
		token.y = t.index
	case:
		token.x = t.index
		token.kind = get_kind(t.current)
		tok.advance(t)
		token.y = t.index
	}

	return
}

get_kind :: proc(r: rune) -> Token_Kind {
	switch r {
	case utf8.RUNE_EOF:
		return .EOF
	case ',':
		return .Comma
	case '{':
		return .Open_Brace
	case '}':
		return .Close_Brace
	case '[':
		return .Open_Bracket
	case ']':
		return .Close_Bracket
	case '=':
		return .Equal
	case:
		return .Invalid
	}
}


consume_comment :: proc(t: ^Tokenizer) {
	for t.current != '\n' && t.current != utf8.RUNE_EOF {
		tok.advance(t)
	}
}


consume_ident :: proc(t: ^Tokenizer) {
	for is_letter(t.current) || is_number(t.current) || t.current == '_' {
		tok.advance(t)
	}
}


consume_string :: proc(t: ^Tokenizer) -> string {
	quote := t.current
	tok.advance(t)
	start := t.index
	end := t.index
	for t.current != utf8.RUNE_EOF {
		r := t.current
		end = t.index
		tok.advance(t)
		if r < 0 {
			// just considering the string as finished
			break
		}
		if r == quote {
			break
		}
		if r == '\\' {
			scan_escape(t)
		}
	}

	return tok.get_value(t, {start, end})
}

consume_number :: proc(t: ^Tokenizer) -> Token_Kind {
	with_decimal_point := false

	loop: for t.current != utf8.RUNE_EOF {
		tok.advance(t)
		switch t.current {
		case '0' ..= '9':
		// okay
		case '.':
			assert(!with_decimal_point, "already has a decimal point")
			with_decimal_point = true
			continue
		case:
			break loop
		}
	}

	return .Float if with_decimal_point else .Integer
}

scan_escape :: proc(t: ^Tokenizer) -> bool {
	switch t.current {
	case '"', '\'', '\\', '/', 'b', 'n', 'r', 't', 'f':
		tok.advance(t)
		return true
	case 'u':
		// Expect 4 hexadecimal digits
		for i := 0; i < 4; i += 1 {
			tok.advance(t)
			switch t.current {
			case '0' ..= '9', 'a' ..= 'f', 'A' ..= 'F':
			// Okay
			case:
				return false
			}
		}
		return true
	case:
		// Ignore the next rune regardless
		tok.advance(t)
	}
	return false
}


get_span_value :: proc(t: ^Tokenizer, token: Token) -> string {
	return st.get_content(t.source, token)
}