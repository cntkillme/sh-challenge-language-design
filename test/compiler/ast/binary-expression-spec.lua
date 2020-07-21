local region = require("compiler.region")
local number_literal = require("compiler.ast.number-literal")
local binary_expression = require("compiler.ast.binary-expression")

--- @param self test_suite
return function(self)
	self:is_truthy(binary_expression.valid_operator("+"))
	self:is_truthy(binary_expression.valid_operator("-"))
	self:is_truthy(binary_expression.valid_operator("*"))
	self:is_truthy(binary_expression.valid_operator("/"))
	self:is_truthy(binary_expression.valid_operator("%"))
	self:is_truthy(binary_expression.valid_operator("^"))
	self:is_falsy(binary_expression.valid_operator("$"))

	-- 123 + 456
	local node = binary_expression.new(
		number_literal.new("123", region.from_lexeme("123", 1, 1, 0)),
		number_literal.new("456", region.from_lexeme("456", 1, 7, 6)),
		"+"
	)

	self:is_equal(node:kind(), binary_expression)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())

	self:is_equal(node.region, {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 9,
		first_position = 0,
		last_position = 8
	})

	self:did_invoke_pass(node.accept, node, {
		visit_binary_expression = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
