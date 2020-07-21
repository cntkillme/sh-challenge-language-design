local region = require("compiler.region")
local number_literal = require("compiler.ast.number-literal")

--- @param self test_suite
return function(self)
	self:is_truthy(number_literal.valid_lexeme("1"))
	self:is_truthy(number_literal.valid_lexeme("123"))
	self:is_truthy(number_literal.valid_lexeme("123.456"))
	self:is_falsy(number_literal.valid_lexeme(""))
	self:is_falsy(number_literal.valid_lexeme("abc"))
	self:is_falsy(number_literal.valid_lexeme("123."))
	self:is_falsy(number_literal.valid_lexeme(".123"))
	local node = number_literal.new("123.456", region.from_lexeme("123.456"))
	self:is_equal(node:kind(), number_literal)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())

	self:is_equal(node.region, {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 7,
		first_position = 0,
		last_position = 6
	})

	self:did_invoke_pass(node.accept, node, {
		visit_number_literal = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
