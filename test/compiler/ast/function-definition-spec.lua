local region = require("compiler.region")
local identifier = require("compiler.ast.identifier")
local binary_expression = require("compiler.ast.binary-expression")
local function_definition = require("compiler.ast.function-definition")

--- @param self test_suite
return function(self)
	-- add(x, y) = x + y
	local node = function_definition.new(
		-- add
		identifier.new("func", region.from_lexeme("add")), {
			--     x
			identifier.new("x", region.from_lexeme("x", 1, 5, 4)),
			--        y
			identifier.new("y", region.from_lexeme("x", 1, 8, 7)),
		},
		--             x + y
		binary_expression.new(
			--             x
			identifier.new("x", region.from_lexeme("x", 1, 13, 12)),
			--                 y
			identifier.new("y", region.from_lexeme("y", 1, 17, 16)),
			"+"
		)
	)

	self:is_equal(node:kind(), function_definition)
	self:is_truthy(node:is_statement())
	self:is_falsy(node:is_expression())

	self:is_equal(node.region, {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 17,
		first_position = 0,
		last_position = 16
	})

	self:did_invoke_pass(node.accept, node, {
		visit_function_definition = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
