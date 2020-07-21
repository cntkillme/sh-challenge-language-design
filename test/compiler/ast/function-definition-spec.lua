local identifier = require("compiler.ast.identifier")
local binary_expression = require("compiler.ast.binary-expression")
local function_definition = require("compiler.ast.function-definition")

--- @param self test_suite
return function(self)
	-- add(x, y) = x + y
	local node = function_definition.new(
		identifier.new("func"),
		{ identifier.new("x"), identifier.new("y") },
		binary_expression.new(identifier.new("x"), identifier.new("y"), "+")
	)

	self:is_equal(node:kind(), function_definition)
	self:is_truthy(node:is_statement())
	self:is_falsy(node:is_expression())

	self:did_invoke_pass(node.accept, node, {
		visit_function_definition = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
