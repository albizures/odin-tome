package lines_core

import "../../st"
import tok "../../tokenizer"
import "core:fmt"
import "core:log"
import "core:strings"

Span_Lines_Opts :: struct {
	before: int,
	after:  int,
}

default_span_lines_opts: Span_Lines_Opts : {before = 1, after = 1}

// by given a span the procedure returns lines where the span is.
// optionally if given options it can return some lines before or after the span.
get_span_lines :: proc(
	source: string,
	span: st.Span,
	opts: Span_Lines_Opts = default_span_lines_opts,
	allocator := context.allocator,
) -> (
	result: [dynamic]Line,
	result_span: st.Span,
) {
	result = make([dynamic]Line, allocator)

	// 1. first we go the start or end of the span
	t_start := create_tokenizer(source)
	move_to(&t_start, span.x)

	t_end := t_start
	move_to(&t_end, span.y)

	result_span.x = t_start.line
	result_span.y = t_end.line + 1 // include the line after the span

	// 2. then we rollback/advance to the lines before or after the span
	for i in 0 ..< opts.before {
		_, err := rollback(&t_start)
		if err != .None {
			break
		}
	}

	for i in 0 ..< (1 + opts.after) {
		_, err := advance(&t_end)
		if err != .None {
			break
		}
	}

	// 3. then we collect the lines between the start and end tokens
	for {
		if t_start.index >= t_end.index {
			break
		}

		line, err := advance(&t_start)
		if err == .None {
			append(&result, line)
		} else {
			break
		}
	}

	return
}


highlight_span :: proc(source: string, span: st.Span, allocator := context.allocator) -> string {
	b := strings.builder_make(context.temp_allocator)
	defer strings.builder_destroy(&b)
	lines, lines_span := get_span_lines(
		source,
		span,
		default_span_lines_opts,
		context.temp_allocator,
	)
	defer delete(lines)

	for line in lines {
		is_highlighted := is_within_span(lines_span, line.index)

		fmt.sbprintf(
			&b,
			" %s %i│ %s\n",
			is_highlighted ? ">" : " ",
			line.index + 1,
			tok.get_value(source, line),
		)
		if is_highlighted {
			strings.write_string(&b, "    │ ")
			for index in line.x ..< line.y {
				strings.write_string(&b, is_within_span(span, index) ? "^" : " ")
			}
			strings.write_string(&b, "\n")
		}
	}

	return strings.clone(strings.to_string(b), allocator)
}

is_within_span :: proc(span: st.Span, offset: int) -> bool {
	return offset >= span.x && offset < span.y
}

move_to_start_of_line :: proc(t: ^Tokenizer) {
	if !is_start_of_line(t) {
		for {
			if t.index == 0 || tok.get_prev(t) == '\n' {
				break
			}
			tok.rollback(t)
		}
	}
}

move_to :: proc(t: ^Tokenizer, offset: int) {
	for {
		line, err := advance(t)
		if err != .None {
			break
		}
		if offset >= line.span.x && offset <= line.span.y {
			rollback(t)
			break
		}
	}
}
