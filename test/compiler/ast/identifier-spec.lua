local region = require("compiler.region")
local identifier = require("compiler.ast.identifier")

--- @param self test_suite
return function(self)
	self:is_truthy(identifier.valid_lexeme("a"))
	self:is_truthy(identifier.valid_lexeme("ab"))
	self:is_truthy(identifier.valid_lexeme("a1"))
	self:is_falsy(identifier.valid_lexeme(""))
	self:is_falsy(identifier.valid_lexeme("1"))
	self:is_falsy(identifier.valid_lexeme("1a"))
	local node = identifier.new("abc", region.from_lexeme("abc"))
	self:is_equal(node:kind(), identifier)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())

	self:is_equal(node.region, {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 3,
		first_position = 0,
		last_position = 2
	})

	self:did_invoke_pass(node.accept, node, {
		visit_identifier = function(_, node2)
			self:is_equal(node2, node)
		end
	})
end
