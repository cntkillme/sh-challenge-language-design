local identifier = require("compiler.ast.identifier")
local number_literal = require("compiler.ast.number-literal")
local call_expression = require("compiler.ast.call-expression")
local unary_expression = require("compiler.ast.unary-expression")
local binary_expression = require("compiler.ast.binary-expression")

--- @param self test_suite
return function(self)
	-- func(31 + xyz, 2 * -9)
	local node = call_expression.new(
		identifier.new("func"),

		{
			binary_expression.new(number_literal.new("31"), identifier.new("xyz")),
			binary_expression.new(number_literal.new("2"), unary_expression.new(number_literal.new("9"), "-"))
		}
	)

	self:is_equal(node:kind(), call_expression)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())

	self:did_invoke_pass(node.accept, node, {
		visit_call_expression = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
