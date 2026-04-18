package st_src

// [start, end]
Span :: [2]int

// [row, col]
Pos :: [2]int

Loc :: struct {
	span: Span,
	pos:  Pos,
}


get_content_from_loc :: proc(source: string, loc: Loc) -> string {
	return source[loc.span.x:loc.span.y]
}

get_content_from_span :: proc(source: string, span: Span) -> string {
	return source[span.x:span.y]
}

get_content :: proc {
	get_content_from_loc,
	get_content_from_span,
}
