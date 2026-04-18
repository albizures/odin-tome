package lines_core

import "../../st"
import tok "../../tokenizer"
import "core:log"


Line_Error :: enum {
	None,
	Already_At_End,
	Already_At_Start,
}

Line :: struct {
	using span: st.Span,
	index:      int,
}

Tokenizer :: struct {
	using tok: tok.Tokenizer,
	line:      int,
}

create_tokenizer :: proc(source: string) -> Tokenizer {
	return Tokenizer{tok = tok.create(source)}
}

get_lines :: proc(source: string, allocator := context.allocator) -> [dynamic]Line {
	t := create_tokenizer(source)

	start := 0
	lines := make([dynamic]Line, allocator)

	for {
		line, err := advance(&t)
		if err == .None {
			append(&lines, line)
		} else {
			break
		}

		if tok.is_eof(t) {
			break
		}
	}

	return lines
}


advance :: proc(t: ^Tokenizer) -> (line: Line, err: Line_Error) {
	if tok.is_eof(t^) {
		err = .Already_At_End
		return
	}

	// if we are not at the start of a line, skip to the next newline
	if !is_start_of_line(t) {
		for {
			if tok.is_eof(t^) {
				err = .Already_At_End
				return
			}

			if t.current == '\n' {
				t.line += 1
				tok.advance(t)
				break
			}

			tok.advance(t)
		}
	}

	start := t.index
	for {
		if t.current == '\n' || tok.is_eof(t^) {
			t.line += 1

			break
		}

		tok.advance(t)
	}

	line = {
		span  = {start, t.index},
		index = t.line - 1,
	}

	tok.advance(t) // advance the newline

	return
}

rollback :: proc(t: ^Tokenizer) -> (line: Line, err: Line_Error) {
	if t.index == 0 {
		err = .Already_At_Start
		return
	}

	end := -1

	// rollback to the end of the current line
	for { 	// in this way we can support the tokenizer to be in the middle of a line`
		if t.current == '\n' {
			end = t.index
			tok.rollback(t)
			break
		}
		tok.rollback(t)
	}

	if end == -1 {
		// reached the start of the file, can't rollback further
		err = .Already_At_Start
		return
	}

	for {
		if is_start_of_line(t) {
			t.line -= 1

			break
		}

		tok.rollback(t)
	}

	line = {
		span  = {t.index, end},
		index = t.line,
	}

	return
}

is_start_of_line :: proc(t: ^Tokenizer) -> bool {
	return t.index == 0 || tok.get_prev(t) == '\n'
}
