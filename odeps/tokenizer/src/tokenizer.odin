package tokenizer_core

import "../../st"
import "core:log"
import "core:unicode/utf8"

Tokenizer :: struct {
	source:  string,
	current: rune,
	index:   int,
	width:   int,
}

Token :: struct {
	using span: st.Span,
}

create_tokenizer :: proc(source: string) -> Tokenizer {
	t := Tokenizer {
		source = source,
	}

	advance_rune(&t)

	return t
}

advance_rune :: proc(t: ^Tokenizer) {
	if t.index >= len(t.source) {
		t.current = utf8.RUNE_EOF
		t.index = len(t.source)
	} else {
		t.index += t.width
		t.current, t.width = utf8.decode_rune_in_string(t.source[t.index:])
		if t.index >= len(t.source) {
			t.current = utf8.RUNE_EOF
		}
	}
}

rollback_rune :: proc(t: ^Tokenizer) {
	if t.index == 0 {
		return
	}

	t.current, t.width = utf8.decode_last_rune(t.source[:t.index])
	t.index -= t.width
}

get_value_from_tokenizer :: proc(t: Tokenizer, token: st.Span) -> string {
	return t.source[token.x:token.y]
}

get_value_from_source :: proc(source: string, token: st.Span) -> string {
	return source[token.x:token.y]
}

move_to :: proc(t: ^Tokenizer, index: int) {
	if index >= len(t.source) {
		t.index = len(t.source)
		t.current = utf8.RUNE_EOF
		t.width = 0
	} else {
		t.index = index
		t.current, t.width = utf8.decode_rune_in_string(t.source[t.index:])
	}
}

is_eof :: proc(t: Tokenizer) -> bool {
	return t.current == utf8.RUNE_EOF
}

get_prev :: proc(t: Tokenizer) -> rune {
	if t.index == 0 {
		return utf8.RUNE_EOF
	}

	r, _ := utf8.decode_last_rune(t.source[:t.index])

	return r
}
