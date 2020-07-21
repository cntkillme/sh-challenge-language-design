local program = require("compiler.ast.program")
local identifier = require("compiler.ast.identifier")
local number_literal = require("compiler.ast.number-literal")
local ast_constrainer = require("compiler.visitors.ast-constrainer")
local call_expression = require("compiler.ast.call-expression")
local unary_expression = require("compiler.ast.unary-expression")
local binary_expression = require("compiler.ast.binary-expression")
local function_definition = require("compiler.ast.function-definition")
local variable_assignment = require("compiler.ast.variable-assignment")
local variable_definition = require("compiler.ast.variable-definition")

local function test_constrainer_success(self)
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

	local visitor = ast_constrainer.new()
	node:accept(visitor)

	if #visitor:diagnostics() > 0 then
		local diagnostics = {}

		for _, diagnostic in ipairs(visitor:diagnostics()) do
			if diagnostic.node and diagnostic.node.lexeme then
				table.insert(diagnostics, diagnostic.message .. " (" .. diagnostic.node.lexeme .. ")")
			else
				table.insert(diagnostics, diagnostic.message)
			end
		end

		self:fail("constrainer diagnostics: " .. table.concat(diagnostics, ", "))
	else
		self:pass()
	end
end

local function test_constrainer_failure(self)
	--- let f() = 0
	--- let f() = g(x)        # duplicate identifier f, unknown identifier g, unknown identifier x
	--- let g(x, x) = 0       # duplicate parameter x
	--- let h2(x) = 0
	--- let f2(x) = f2(x - 1) # unknown identifier f2
	--- let x2 = x2 + 1       # unknown identifier x2
	--- let x
	--- let x = y             # duplicate identifier x, unknown identifier y
	--- f = 5                 # attempt to assign to a function
	--- let h = x()           # attempt to call a variable x
	--- h = g()               # argument count differs from parameter count
	--- h = f(5)              # argument count differs from parameter count
	--- let m() = f           # expected expression
	--- let n = f             # expected expression
	--- let p(h) = h + x
	--- return 0
	local node = program.new(
		{
			function_definition.new(identifier.new("f"), {}, number_literal.new("0")),

			function_definition.new(
				identifier.new("f"),
				{},
				call_expression.new(identifier.new("g"), { identifier.new("x") })
			),

			function_definition.new(
				identifier.new("g"),
				{ identifier.new("x"), identifier.new("x") },
				number_literal.new("0")
			),

			function_definition.new(identifier.new("h2"), { identifier.new("x") }, number_literal.new("0")),

			function_definition.new(
				identifier.new("f2"),
				{ identifier.new("x") },

				call_expression.new(
					identifier.new("f2"),
					{ binary_expression.new(identifier.new("x"), number_literal.new("1"), "-") }
				)
			),

			variable_definition.new(
				identifier.new("x2"),
				binary_expression.new(identifier.new("x2"), number_literal.new("1"), "-")
			),

			variable_definition.new(identifier.new("x")),
			variable_definition.new(identifier.new("x"), identifier.new("y")),
			variable_assignment.new(identifier.new("f"), number_literal.new("5")),
			variable_definition.new(identifier.new("h"), call_expression.new(identifier.new("x"), {})),
			variable_assignment.new(identifier.new("h"), call_expression.new(identifier.new("g"), {})),

			variable_assignment.new(
				identifier.new("h"),
				call_expression.new(identifier.new("f"),
				{ number_literal.new("5") })
			),

			function_definition.new(identifier.new("m"), {}, identifier.new("f")),
			variable_definition.new(identifier.new("n"), identifier.new("f")),

			function_definition.new(
				identifier.new("p"),
				{ identifier.new("h") },
				binary_expression.new(identifier.new("h"), identifier.new("x"), "+")
			)
		},

		number_literal.new("0")
	)

	local visitor = ast_constrainer.new()
	local diagnostics = {}

	local expectedDiagnostics = {
		"duplicate identifier",
		"unknown identifier",
		"unknown identifier",
		"duplicate parameter",
		"unknown identifier",
		"unknown identifier",
		"duplicate identifier",
		"unknown identifier",
		"attempt to assign to a function",
		"attempt to call a variable",
		"argument count differs from parameter count",
		"argument count differs from parameter count",
		"expected expression",
		"expected expression"
	}

	node:accept(visitor)

	for _, diagnostic in ipairs(visitor:diagnostics()) do
		table.insert(diagnostics, diagnostic.message)
	end

	self:is_equal(diagnostics, expectedDiagnostics)
end

--- @param self test_suite
return function(self)
	test_constrainer_success(self)
	test_constrainer_failure(self)
end
