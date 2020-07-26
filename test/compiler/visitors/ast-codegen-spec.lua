local program = require("compiler.ast.program")
local identifier = require("compiler.ast.identifier")
local ast_codegen = require("compiler.visitors.ast-codegen")
local number_literal = require("compiler.ast.number-literal")
local ast_constrainer = require("compiler.visitors.ast-constrainer")
local call_expression = require("compiler.ast.call-expression")
local unary_expression = require("compiler.ast.unary-expression")
local binary_expression = require("compiler.ast.binary-expression")
local function_definition = require("compiler.ast.function-definition")
local variable_assignment = require("compiler.ast.variable-assignment")
local variable_definition = require("compiler.ast.variable-definition")

--- @param self test_suite
local function test_codegen_success(self)
	-- let x
	-- let pi = 3.14
	-- let f(x) = pi * x
	-- let g(x, y) = f(x - y)
	-- x = -10 / (2 ^ (3 % 1))
	-- return g($0 + x, pi)
	local node = program.new(
		{
			variable_definition.new(identifier.new("x")),
			variable_definition.new(identifier.new("pi"), number_literal.new("3.14")),

			function_definition.new(
				identifier.new("f"),
				{ identifier.new("x") },
				binary_expression.new(identifier.new("pi"), identifier.new("x"), "*")
			),

			function_definition.new(
				identifier.new("g"),
				{ identifier.new("x"), identifier.new("y") },

				call_expression.new(
					identifier.new("f"),
					{ binary_expression.new(identifier.new("x"), identifier.new("y"), "-") }
				)
			),

			variable_assignment.new(
				identifier.new("x"),

				binary_expression.new(
					unary_expression.new(number_literal.new("10"), "-"),

					binary_expression.new(
						number_literal.new("2"),
						binary_expression.new(number_literal.new("3"), number_literal.new("1"), "%"),
						"^"
					),

					"/"
				)
			)
		},

		call_expression.new(
			identifier.new("g"),

			{
				binary_expression.new(unary_expression.new(number_literal.new("0"), "$"), identifier.new("x"), "+"),
				identifier.new("pi")
			}
		)
	)

	-- SHLang-1			| 53 48 4C 61 6E 67 2D 31
	--				 let x
	-- imm 0			| 07 00 00 00 00 00 00 00 00
	-- 			let pi = 3.14
	-- imm 3.14			| 07 1F 85 EB 51 B8 1E 09 40
	-- 			x = -10 / (2 ^ (3 % 1))
	-- imm 10			| 07 00 00 00 00 00 00 24 40
	-- neg				| 06
	-- imm 2			| 07 00 00 00 00 00 00 00 40
	-- imm 3			| 07 00 00 00 00 00 00 08 40
	-- imm 1			| 07 00 00 00 00 00 00 F0 3F
	-- rem				| 04
	-- exp				| 05
	-- div				| 03
	--		 return g($0 + x, pi)
	-- rep 0			| 09 00
	-- imm 0			| 07 00 00 00 00 00 00 00 00
	-- inp				| 0B
	-- cpy 0			| 08 00
	-- add				| 00
	-- cpy 1			| 08 01
	-- arg 2			| 0C 02
	-- inv 7			| 0D 07 00 00 00
	-- ret				| 0E
	--            let f(x) = pi * x
	-- gbl 1			| 0A 01
	-- cpy 0			| 08 00
	-- mul				| 02
	-- ret				| 0E
	--            let g(x, y) = f(x - y)
	-- cpy 0			| 08 00
	-- cpy 1			| 08 01
	-- sub				| 01
	-- arg 1			| 0C 01
	-- inv -18			| 0D EE FF FF FF
	-- ret				| 0E

	local bytecode = (
		"53 48 4C 61 6E 67 2D 31 07 00 00 00 00 00 00 00 00 07 1F 85 EB 51 B8 1E 09 40 07 00 00 00 00 00 00 24 40 " ..
		"06 07 00 00 00 00 00 00 00 40 07 00 00 00 00 00 00 08 40 07 00 00 00 00 00 00 F0 3F 04 05 03 09 00 07 00 " ..
		"00 00 00 00 00 00 00 0B 08 00 00 08 01 0C 02 0D 07 00 00 00 0E 0A 01 08 00 02 0E 08 00 08 01 01 0C 01 0D " ..
		"EE FF FF FF 0E"
	):gsub("(%S+) ?", function(ptn) return string.char(tonumber(ptn, 16)) end)

	local constrainer = ast_constrainer.new()
	local codegen = ast_codegen.new()
	node:accept(constrainer)
	self:is_equal(constrainer:diagnostics(), {})
	node:accept(codegen)
	self:is_equal(codegen:diagnostics(), {})
	self:is_equal(codegen:content(), bytecode)
end

--- @param self test_suite
local function test_codegen_success_2(self)
	-- see resources/compiler/test.txt
	local node = program.new(
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

	-- see resources/compiler/test.txt
	local bytecode = (
		"53 48 4C 61 6E 67 2D 31 07 6F 12 83 C0 CA 21 09 40 07 00 00 00 00 00 00 59 40 08 01 0C 01 0D 67 00 00 00 " ..
		"09 01 08 01 08 01 08 01 0C 03 0D 4C 00 00 00 09 01 07 00 00 00 00 00 00 00 00 08 02 0B 08 02 07 00 00 00 " ..
		"00 00 00 F0 3F 00 0B 08 02 0B 07 00 00 00 00 00 00 00 40 00 0C 03 0D 1D 00 00 00 08 01 06 03 08 00 07 00 " ..
		"00 00 00 00 00 00 40 06 05 07 00 00 00 00 00 00 59 40 04 00 0E 08 00 08 01 00 08 02 0A 00 02 01 0E 0A 01 " ..
		"07 00 00 00 00 00 00 00 00 08 00 0C 03 0D E0 FF FF FF 0E"
	):gsub("(%S+) ?", function(ptn) return string.char(tonumber(ptn, 16)) end)

	local constrainer = ast_constrainer.new()
	local codegen = ast_codegen.new()
	node:accept(constrainer)
	self:is_equal(constrainer:diagnostics(), {})
	node:accept(codegen)
	self:is_equal(codegen:diagnostics(), {})
	self:is_equal(codegen:content(), bytecode)
end

--- @param self test_suite
local function test_codegen_failure(self)
	local params = {}
	local defns = {}

	for idx = 1, 256 do
		table.insert(params, identifier.new("p" .. idx))
	end

	for idx = 1, 257 do
		table.insert(defns, variable_definition.new(identifier.new("v" .. idx)))
		table.insert(defns, function_definition.new(identifier.new("f" .. idx), {}, number_literal.new("0")))
	end

	local node = program.new(
		{
			function_definition.new(identifier.new("f"), params, number_literal.new("0")),
			table.unpack(defns)
		},

		number_literal.new("0")
	)

	local expectedDiagnostics = {
		"too many variables",
		"too many parameters",
		"too many functions"
	}

	local constrainer = ast_constrainer.new()
	local codegen = ast_codegen.new()
	local diagnostics = {}
	node:accept(constrainer)
	self:is_equal(constrainer:diagnostics(), {})
	node:accept(codegen)


	for _, diagnostic in ipairs(codegen:diagnostics()) do
		table.insert(diagnostics, diagnostic.message)
	end

	self:is_equal(diagnostics, expectedDiagnostics)
end

--- @param self test_suite
return function(self)
	test_codegen_success(self)
	test_codegen_success_2(self)
	test_codegen_failure(self)
end
