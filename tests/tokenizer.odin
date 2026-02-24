package tome_tests

import tome "../src"
import "core:fmt"
import "core:log"
import "core:testing"

@(test)
test_ident_and_number2 :: proc(t: ^testing.T) {
	tokenizer := tome.make_tokenizer("test=123")

	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Ident, span = {0, 4}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Equal, span = {4, 5}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .Integer, span = {5, 8}})
	testing.expect_value(t, tome.get_token(&tokenizer), tome.Token{kind = .EOF, span = {8, 8}})
}


// @(test)
// test_ident_and_string2 :: proc(t: ^testing.T) {
// 	using config
// 	tokenizer := make_tokenizer(`test="123"`)

// 	testing.expect_value(t, get_token(&tokenizer), Ident_Token{value = "test", span = {0, 4}})
// 	testing.expect_value(t, get_token(&tokenizer), Equal_Token{span = {4, 5}})
// 	testing.expect_value(t, get_token(&tokenizer), Value_Token{span = {5, 10}, value = "123"})
// 	testing.expect_value(t, get_token(&tokenizer), EOF_Token{span = {10, 10}})
// }


// @(test)
// test_ident_and_multiline2 :: proc(t: ^testing.T) {
// 	using config

// 	tokenizer := make_tokenizer(`test="""
// 123
// 345
// """
// `)

// 	testing.expect_value(t, get_token(&tokenizer), Ident_Token{value = "test", span = {0, 4}})
// 	testing.expect_value(t, get_token(&tokenizer), Equal_Token{span = {4, 5}})
// 	testing.expect_value(t, get_token(&tokenizer), Value_Token{span = {5, 20}, value = "123\n345"})
// 	testing.expect_value(t, get_token(&tokenizer), EOF_Token{span = {21, 21}})
// }
