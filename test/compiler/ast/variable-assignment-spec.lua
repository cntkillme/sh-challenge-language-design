local identifier = require("compiler.ast.identifier")
local number_literal = require("compiler.ast.number-literal")
local call_expression = require("compiler.ast.call-expression")
local unary_expression = require("compiler.ast.unary-expression")
local binary_expression = require("compiler.ast.binary-expression")
local variable_assignment = require("compiler.ast.variable-assignment")

--- @param self test_suite
return function(self)
	-- x = f(31 + xyz, 2 * -9)
	local node = variable_assignment.new(
		identifier.new("x"),

		call_expression.new(
			identifier.new("func"),
			{
				binary_expression.new(number_literal.new("31"), identifier.new("xyz", "+")),
				binary_expression.new(number_literal.new("2"), unary_expression.new(number_literal.new("9"), "-"), "*")
			}
		)
	)

	self:is_equal(node:kind(), variable_assignment)
	self:is_truthy(node:is_statement())
	self:is_falsy(node:is_expression())

	self:did_invoke_pass(node.accept, node, {
		visit_variable_assignment = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
