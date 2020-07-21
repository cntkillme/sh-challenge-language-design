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
	local node = binary_expression.new(number_literal.new("123"), number_literal.new("456"), "+")
	self:is_equal(node:kind(), binary_expression)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())

	self:did_invoke_pass(node.accept, node, {
		visit_binary_expression = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
