local program = require("compiler.ast.program")
local identifier = require("compiler.ast.identifier")
local number_literal = require("compiler.ast.number-literal")
local call_expression = require("compiler.ast.call-expression")
local binary_expression = require("compiler.ast.binary-expression")
local function_definition = require("compiler.ast.function-definition")

--- @param self test_suite
return function(self)
	-- let f(x) = x + 5
	-- return f(5)
	local node = program.new(
		{
			function_definition.new(
				identifier.new("f"),
				{ identifier.new("x") },
				binary_expression.new(identifier.new("x"), number_literal.new("5"), "+")
			)
		},

		call_expression.new(identifier.new("f"), { number_literal.new("5") })
	)

	self:is_equal(node:kind(), program)
	self:is_falsy(node:is_statement())
	self:is_falsy(node:is_expression())

	self:did_invoke_pass(node.accept, node, {
		visit_program = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
