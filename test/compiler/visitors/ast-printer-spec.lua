local program = require("compiler.ast.program")
local identifier = require("compiler.ast.identifier")
local ast_printer = require("compiler.visitors.ast-printer")
local number_literal = require("compiler.ast.number-literal")
local call_expression = require("compiler.ast.call-expression")
local unary_expression = require("compiler.ast.unary-expression")
local binary_expression = require("compiler.ast.binary-expression")
local function_definition = require("compiler.ast.function-definition")
local variable_assignment = require("compiler.ast.variable-assignment")
local variable_definition = require("compiler.ast.variable-definition")

--- @param self test_suite
return function(self)
	-- let f(x, y) = x + (((y * x) / y) % 1)
	-- let x = f(31, 2 * -9)
	-- x = x^-2
	-- return x^-2
	local node = program.new(
		{
			function_definition.new(
				identifier.new("f"),
				{ identifier.new("x"), identifier.new("y") },

				binary_expression.new(
					identifier.new("x"),

					binary_expression.new(
						binary_expression.new(
							binary_expression.new(identifier.new("y"), identifier.new("x"), "*"),
							identifier.new("y"),
							"/"
						),

						number_literal.new("1"),
						"%"
					),

					"+"
				)
			),

			variable_definition.new(
				identifier.new("x"),

				call_expression.new(
					identifier.new("f"),
					{
						number_literal.new("31"),

						binary_expression.new(
							number_literal.new("2"),
							unary_expression.new(number_literal.new("9"), "-"),
							"*"
						)
					}
				)
			),

			variable_assignment.new(
				identifier.new("x"),
				binary_expression.new(identifier.new("x"), unary_expression.new(number_literal.new("2"), "-"), "^")
			)
		},

		binary_expression.new(identifier.new("x"), unary_expression.new(number_literal.new("2"), "-"), "^")
	)

	local chunk1 = [[
let f(x, y) = x + y * x / y % 1
let x = f(31, 2 * -9)
x = x ^ -2

return x ^ -2
]]

	local chunk2 = [[
let f(x, y) = (x + (((y * x) / y) % 1))
let x = f(31, (2 * -9))
x = (x ^ -2)

return (x ^ -2)
]]

	local visitor1 = ast_printer.new()
	local visitor2 = ast_printer.new(true)
	node:accept(visitor1)
	node:accept(visitor2)
	self:is_equal(visitor1:content(), chunk1)
	self:is_equal(visitor2:content(), chunk2)
end
