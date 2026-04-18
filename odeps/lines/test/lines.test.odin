package lines_test


import tok "../../tokenizer"
import "../src"
import "core:log"
import "core:testing"

@(test)
test_get_lines :: proc(t: ^testing.T) {
	source := "1\n2\n3"
	lines := src.get_lines(source, context.temp_allocator)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, len(lines), 3)
	testing.expect_value(t, lines[0], src.Line{span = {0, 1}, index = 0})
	testing.expect_value(t, lines[1], src.Line{span = {2, 3}, index = 1})
	testing.expect_value(t, lines[2], src.Line{span = {4, 5}, index = 2})
}

@(test)
test_advance :: proc(t: ^testing.T) {
	source := "1\n2\n3"
	to := src.create_tokenizer(source)

	line_1, err_1 := src.advance(&to)
	testing.expect_value(t, line_1, src.Line{span = {0, 1}, index = 0})
	testing.expect_value(t, err_1, src.Line_Error.None)

	line_2, err_2 := src.advance(&to)
	testing.expect_value(t, line_2, src.Line{span = {2, 3}, index = 1})
	testing.expect_value(t, err_2, src.Line_Error.None)

	line_3, err_3 := src.advance(&to)
	testing.expect_value(t, line_3, src.Line{span = {4, 5}, index = 2})
	testing.expect_value(t, err_1, src.Line_Error.None)


	_, err_4 := src.advance(&to)
	testing.expect_value(t, err_4, src.Line_Error.Already_At_End)

	testing.expect_value(t, to.line, 3)
}

@(test)
test_advance_middle_of_line :: proc(t: ^testing.T) {
	source := "123\n456\n789"
	to := src.create_tokenizer(source)

	tok.advance(&to) // current is '2'
	tok.advance(&to) // current is '3'

	line_1, err_1 := src.advance(&to)
	testing.expect_value(t, line_1, src.Line{span = {4, 7}, index = 1})
	testing.expect_value(t, err_1, src.Line_Error.None)
}


@(test)
test_rollback :: proc(t: ^testing.T) {
	source := "1\n2\n3"
	to := src.create_tokenizer(source)

	src.advance(&to)
	src.advance(&to)

	line_1, err_1 := src.rollback(&to)
	testing.expect_value(t, line_1, src.Line{span = {2, 3}, index = 1})
	testing.expect_value(t, err_1, src.Line_Error.None)

	line_2, err_2 := src.rollback(&to)
	testing.expect_value(t, line_2, src.Line{span = {0, 1}, index = 0})
	testing.expect_value(t, err_2, src.Line_Error.None)

	_, err_3 := src.rollback(&to)
	testing.expect_value(t, err_3, src.Line_Error.Already_At_Start)
}

@(test)
test_rollback_middle_of_line :: proc(t: ^testing.T) {
	source := "123\n456\n789"
	to := src.create_tokenizer(source)

	src.advance(&to) // now after \n, at '4'
	tok.advance(&to) // current is '5'

	line_1, err_1 := src.rollback(&to)
	testing.expect_value(t, line_1, src.Line{span = {0, 3}, index = 0})
	testing.expect_value(t, err_1, src.Line_Error.None)
}
