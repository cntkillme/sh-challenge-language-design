local region = require("compiler.region")
local identifier = require("compiler.ast.identifier")
local number_literal = require("compiler.ast.number-literal")
local call_expression = require("compiler.ast.call-expression")
local unary_expression = require("compiler.ast.unary-expression")
local binary_expression = require("compiler.ast.binary-expression")
local variable_assignment = require("compiler.ast.variable-assignment")

--- @param self test_suite
return function(self)
	-- x   =
	-- func  (  31 +xyz,   2 * -9   )
	local node = variable_assignment.new(
		-- x
		identifier.new("x", region.from_lexeme("x")),
		--
		-- func  (  31 +xyz,   2 * -9   )
		call_expression.new(
			--
			-- func
			identifier.new("func", region.from_lexeme("func", 2, 1, 6)), {
				--
				--          31 +xyz
				binary_expression.new(
					--
					--          31
					number_literal.new("31", region.from_lexeme("31", 2, 10, 15)),
					--
					--              xyz
					identifier.new("xyz", region.from_lexeme("xyz", 2, 14, 19))
				),
				--
				--                     2 * -9
				binary_expression.new(
					--
					--                     2
					number_literal.new("2", region.from_lexeme("2", 2, 21, 26)),
					--
					--                         -9
					unary_expression.new(
						--
						--                          9
						number_literal.new("9", region.from_lexeme("9", 2, 26, 31)),
						"-"
					)
				)
			}, {
				--
				--                              )
				first_line = 2,
				last_line = 2,
				first_column = 30,
				last_column = 30,
				first_position = 35,
				last_position = 35
			}
		)
	)

	self:is_equal(node:kind(), variable_assignment)
	self:is_equal(node.target:kind(), identifier)
	self:is_truthy(node:is_statement())
	self:is_falsy(node:is_expression())

	self:is_equal(node.region, {
		first_line = 1,
		last_line = 2,
		first_column = 1,
		last_column = 30,
		first_position = 0,
		last_position = 35
	})

	self:did_invoke_pass(node.accept, node, {
		visit_variable_assignment = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
