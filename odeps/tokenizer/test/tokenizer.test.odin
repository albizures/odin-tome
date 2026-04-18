package tokenizer_test

import src "../src"
import "core:testing"
import "core:unicode/utf8"

@(test)
test_advance_rune :: proc(t: ^testing.T) {
	tok := src.create_tokenizer("ab😅")

	// Initial state after create_tokenizer (which calls advance_rune once)
	testing.expect_value(t, tok.current, 'a')
	testing.expect_value(t, tok.index, 0)
	testing.expect_value(t, tok.width, 1)

	// Second rune
	src.advance_rune(&tok)
	testing.expect_value(t, tok.current, 'b')
	testing.expect_value(t, tok.index, 1)
	testing.expect_value(t, tok.width, 1)

	// Third rune
	src.advance_rune(&tok)
	testing.expect_value(t, tok.current, '😅')
	testing.expect_value(t, tok.index, 2)
	testing.expect_value(t, tok.width, 4)

	// EOF
	src.advance_rune(&tok)
	testing.expect_value(t, tok.current, utf8.RUNE_EOF)
}

@(test)
test_rollback_rune :: proc(t: ^testing.T) {
	tok := src.create_tokenizer("a😀c")

	src.advance_rune(&tok) // 'b'
	src.advance_rune(&tok) // 'c'

	testing.expect_value(t, tok.current, 'c')
	testing.expect_value(t, tok.index, 5)

	src.rollback_rune(&tok)
	testing.expect_value(t, tok.current, '😀')
	testing.expect_value(t, tok.index, 1)

	src.rollback_rune(&tok)
	testing.expect_value(t, tok.current, 'a')
	testing.expect_value(t, tok.index, 0)

	src.rollback_rune(&tok) // should not change (out of bounds)
	testing.expect_value(t, tok.current, 'a')
	testing.expect_value(t, tok.index, 0)
}

@(test)
test_get_prev :: proc(t: ^testing.T) {
	tok := src.create_tokenizer("a😀c")

	// Initially, index is 0, so get_prev should be EOF
	testing.expect_value(t, src.get_prev(tok), utf8.RUNE_EOF)

	src.advance_rune(&tok) // Advances to '😀'
	// Now get_prev should be 'a'
	testing.expect_value(t, src.get_prev(tok), 'a')

	src.advance_rune(&tok) // Advances to 'c'
	// Now get_prev should be '😀'
	testing.expect_value(t, src.get_prev(tok), '😀')
}

@(test)
test_move_to :: proc(t: ^testing.T) {
	tok := src.create_tokenizer("a😀c")
	
	src.move_to(&tok, 1) // Move to '😀'
	testing.expect_value(t, tok.current, '😀')
	testing.expect_value(t, tok.index, 1)
	testing.expect_value(t, tok.width, 4)

	src.move_to(&tok, 0) // Move to 'a'
	testing.expect_value(t, tok.current, 'a')
	testing.expect_value(t, tok.index, 0)
	testing.expect_value(t, tok.width, 1)

	src.move_to(&tok, 5) // Move to 'c'
	testing.expect_value(t, tok.current, 'c')
	testing.expect_value(t, tok.index, 5)
	testing.expect_value(t, tok.width, 1)

	src.move_to(&tok, 6) // EOF
	testing.expect_value(t, tok.current, utf8.RUNE_EOF)
	testing.expect_value(t, tok.index, 6)
	testing.expect_value(t, tok.width, 0)
}

