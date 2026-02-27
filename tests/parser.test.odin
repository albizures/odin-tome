package tome_tests

import tome "../src"
import "core:log"
import "core:testing"


@(test)
test_simple_parse :: proc(t: ^testing.T) {
	value, errors := tome.parse("test=123")

	testing.expect_value(t, len(errors), 0)
	testing.expect_value(t, value["test"].(tome.Integer), 123)
}
