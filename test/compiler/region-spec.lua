local region = require("compiler.region")

--- @param self test_suite
return function(self)
	self:is_equal(region.identity() , {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 1,
		first_position = 0,
		last_position = 0
	})

	self:is_equal(region.from_lexeme("123"), {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 3,
		first_position = 0,
		last_position = 2
	})

	self:is_equal(region.from_lexeme("   123\n456   "), {
		first_line = 1,
		last_line = 2,
		first_column = 1,
		last_column = 6,
		first_position = 0,
		last_position = 12
	})

	self:is_equal(region.from_lexeme("123", 5, 10, 20), {
		first_line = 5,
		last_line = 5,
		first_column = 10,
		last_column = 12,
		first_position = 20,
		last_position = 22
	})

	local str = "abcd\nefgh\nij"

	self:is_equal(region.extend(region.from_lexeme(str), region.from_lexeme(str .. "klm", 5, 3, 50)), {
		first_line = 1,
		last_line = 7,
		first_column = 1,
		last_column = 5,
		first_position = 0,
		last_position = 50 + #str + 2
	})

	self:is_equal(region.extend(region.from_lexeme(str .. "klm", 5, 3, 50), region.from_lexeme(str)), {
		first_line = 1,
		last_line = 7,
		first_column = 1,
		last_column = 5,
		first_position = 0,
		last_position = 50 + #str + 2
	})

	local str1 = "abc"
	local str2 = "abcdefghijklmnopqrstuvwxyz"

	self:is_equal(
		region.transform_left(region.from_lexeme(str2, 1, 4, #str1), region.from_lexeme(str1)),
		region.from_lexeme(str1 .. str2)
	)

	self:is_equal(
		region.transform_right(region.from_lexeme(str2), region.from_lexeme(str1)),
		region.from_lexeme(str2 .. str1)
	)

	str1 = "abc\ndef"

	self:is_equal(
		region.transform_left(region.from_lexeme(str2, 2, 4, #str1), region.from_lexeme(str1)),
		region.from_lexeme(str1 .. str2)
	)

	self:is_equal(
		region.transform_right(region.from_lexeme(str2), region.from_lexeme(str1)),
		region.from_lexeme(str2 .. str1)
	)

	str2 = "abcdefg\nhijklmnop\nqrstuvwxyz"

	self:is_equal(
		region.transform_left(region.from_lexeme(str2, 2, 11, #str1), region.from_lexeme(str1)),
		region.from_lexeme(str1 .. str2)
	)

	self:is_equal(
		region.transform_right(region.from_lexeme(str2), region.from_lexeme(str1)),
		region.from_lexeme(str2 .. str1)
	)

	self:did_invoke_fail(region.from_lexeme, "", 1, 1, 0)
	self:did_invoke_fail(region.from_lexeme, "\n", 1, 1, 0)
	self:did_invoke_fail(region.from_lexeme, "asd\n", 1, 1, 0)
end
