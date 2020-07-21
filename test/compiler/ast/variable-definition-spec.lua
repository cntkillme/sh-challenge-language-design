local identifier = require("compiler.ast.identifier")
local number_literal = require("compiler.ast.number-literal")
local binary_expression = require("compiler.ast.binary-expression")
local variable_definition = require("compiler.ast.variable-definition")

--- @param self test_suite
return function(self)
	-- let x = 10 + y
	local node = variable_definition.new(
		identifier.new("x"),
		binary_expression.new(number_literal.new("10"), identifier.new("y"), "+")
	)

	self:is_equal(node:kind(), variable_definition)
	self:is_truthy(node:is_statement())
	self:is_falsy(node:is_expression())

	self:did_invoke_pass(node.accept, node, {
		visit_variable_definition = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
