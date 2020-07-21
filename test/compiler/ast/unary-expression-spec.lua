local region = require("compiler.region")
local number_literal = require("compiler.ast.number-literal")
local unary_expression = require("compiler.ast.unary-expression")

--- @param self test_suite
return function(self)
	self:is_truthy(unary_expression.valid_operator("-"))
	self:is_truthy(unary_expression.valid_operator("$"))
	self:is_falsy(unary_expression.valid_operator("+"))
	self:is_falsy(unary_expression.valid_operator("*"))
	self:is_falsy(unary_expression.valid_operator("/"))
	self:is_falsy(unary_expression.valid_operator("%"))
	self:is_falsy(unary_expression.valid_operator("^"))
	local node = unary_expression.new(number_literal.new("123", region.from_lexeme("123", 1, 2, 1)), "-")
	self:is_equal(node:kind(), unary_expression)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())

	self:is_equal(node.region, {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 4,
		first_position = 0,
		last_position = 3
	})

	self:did_invoke_pass(node.accept, node, {
		visit_unary_expression = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
