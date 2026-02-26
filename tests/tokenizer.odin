package tome_tests

import tome "../src"
import "core:log"
import "core:testing"

@(test)
test_ident_and_int :: proc(t: ^testing.T) {
	value := "test=123"
	tokenizer := tome.make_tokenizer("test=123")

	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Ident, span = {0, 4}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Equal, span = {4, 5}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Integer, span = {5, 8}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .EOF, span = {8, 8}})
}

@(test)
test_ident_and_decimal :: proc(t: ^testing.T) {
	tokenizer := tome.make_tokenizer("test=123.45")

	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Ident, span = {0, 4}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Equal, span = {4, 5}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Float, span = {5, 11}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .EOF, span = {11, 11}})
}

@(test)
test_ident_and_bool :: proc(t: ^testing.T) {
	tokenizer := tome.make_tokenizer("test=true")

	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Ident, span = {0, 4}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Equal, span = {4, 5}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Bool, span = {5, 9}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .EOF, span = {9, 9}})
}


@(test)
test_ident_and_multiline :: proc(t: ^testing.T) {
	tokenizer := tome.make_tokenizer(`test="
123
345
"
`)

	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Ident, span = {0, 4}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Equal, span = {4, 5}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .String, span = {5, 16}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .EOF, span = {17, 17}})
}


@(test)
test_ident_and_escaping :: proc(t: ^testing.T) {
	tokenizer := tome.make_tokenizer(`test="\
\"123\"
345\
"
`)

	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Ident, span = {0, 4}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Equal, span = {4, 5}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .String, span = {5, 22}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .EOF, span = {23, 23}})
}
