local region = require("compiler.region")
local identifier = require("compiler.ast.identifier")
local number_literal = require("compiler.ast.number-literal")
local call_expression = require("compiler.ast.call-expression")
local unary_expression = require("compiler.ast.unary-expression")
local binary_expression = require("compiler.ast.binary-expression")

--- @param self test_suite
return function(self)
	-- func  (  31 +xyz,   2 * -9   )
	local node = call_expression.new(
		-- func
		identifier.new("func", region.from_lexeme("func")), {
			--          31 +xyz
			binary_expression.new(
				--          31
				number_literal.new("31", region.from_lexeme("31", 1, 10, 9)),
				--              xyz
				identifier.new("xyz", region.from_lexeme("xyz", 1, 14, 13))
			),
			--                     2 * -9
			binary_expression.new(
				--                     2
				number_literal.new("2", region.from_lexeme("2", 1, 21, 20)),
				--                         -9
				unary_expression.new(
					--                          9
					number_literal.new("9", region.from_lexeme("9", 1, 26, 25)),
					"-"
				)
			)
		}, {
			--                              )
			first_line = 1,
			last_line = 1,
			first_column = 30,
			last_column = 30,
			first_position = 29,
			last_position = 29
		}
	)

	self:is_equal(node:kind(), call_expression)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())

	self:is_equal(node.region, {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 30,
		first_position = 0,
		last_position = 29
	})

	self:did_invoke_pass(node.accept, node, {
		visit_call_expression = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
