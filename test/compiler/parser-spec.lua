local parser = require("compiler.parser")
local program = require("compiler.ast.program")
local identifier = require("compiler.ast.identifier")
local ast_printer = require("compiler.visitors.ast-printer")
local input_stream = require("input-stream")
local number_literal = require("compiler.ast.number-literal")
local call_expression = require("compiler.ast.call-expression")
local unary_expression = require("compiler.ast.unary-expression")
local binary_expression = require("compiler.ast.binary-expression")
local function_definition = require("compiler.ast.function-definition")
local variable_assignment = require("compiler.ast.variable-assignment")
local variable_definition = require("compiler.ast.variable-definition")

--- @param self test_suite
--- @param ast abstract_node
--- @param expected abstract_node
local function compare_ast(self, ast, expected)
	local p1 = ast_printer.new(true)
	local p2 = ast_printer.new(true)
	ast:accept(p1)
	expected:accept(p2)
	local gotIter = p1:content():gmatch("[^\n]+")
	local expectedIter = p2:content():gmatch("[^\n]+")

	while true do
		local gotLine = gotIter()
		local expectedLine = expectedIter()
		self:is_equal(gotLine or "", expectedLine or "")

		if not (gotLine or expectedLine) then
			break
		end
	end
end

--- @param self test_suite
return function(self)
	local ast = parser.new(input_stream.from_file("resources/compiler/test.txt")):parse()

	local expected = program.new(
		{
			variable_definition.new(identifier.new("PI"), number_literal.new("3.1415")),
			variable_definition.new(identifier.new("x"), number_literal.new("100")),

			function_definition.new(
				identifier.new("f"),
				{ identifier.new("x"), identifier.new("y"), identifier.new("z") },

				binary_expression.new(
					binary_expression.new(identifier.new("x"), identifier.new("y"), "+"),
					binary_expression.new(identifier.new("z"), identifier.new("PI"), "*"),
					"-"
				)
			),

			function_definition.new(
				identifier.new("g"),
				{ identifier.new("z") },

				call_expression.new(
					identifier.new("f"),
					{ identifier.new("x"), number_literal.new("0"), identifier.new("z") }
				)
			),

			variable_assignment.new(
				identifier.new("x"),
				call_expression.new(identifier.new("g"), { identifier.new("x") })
			),

			variable_assignment.new(
				identifier.new("x"),

				call_expression.new(
					identifier.new("f"),
					{ identifier.new("x"), identifier.new("x"), identifier.new("x") }
				)
			),

			variable_definition.new(identifier.new("y"))
		},

		binary_expression.new(
			binary_expression.new(
				call_expression.new(
					identifier.new("f"),

					{
						unary_expression.new(identifier.new("y"), "$"),
						unary_expression.new(binary_expression.new(identifier.new("y"), number_literal.new("1"), "+"), "$"),
						binary_expression.new(unary_expression.new(identifier.new("y"), "$"), number_literal.new("2"), "+")
					}
				),

				unary_expression.new(identifier.new("x"), "-"),
				"/"
			),

			binary_expression.new(
				binary_expression.new(identifier.new("PI"), unary_expression.new(number_literal.new("2"), "-"), "^"),
				number_literal.new("100"),
				"%"
			),

			"+"
		)
	)

	compare_ast(self, ast, expected)
end
