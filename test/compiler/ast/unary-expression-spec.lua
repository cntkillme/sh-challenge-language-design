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
	local node = unary_expression.new(number_literal.new("123"), "-")
	self:is_equal(node:kind(), unary_expression)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())

	self:did_invoke_pass(node.accept, node, {
		visit_unary_expression = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
