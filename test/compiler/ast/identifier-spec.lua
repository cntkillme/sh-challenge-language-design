local identifier = require("compiler.ast.identifier")

--- @param self test_suite
return function(self)
	self:is_truthy(identifier.valid_lexeme("a"))
	self:is_truthy(identifier.valid_lexeme("ab"))
	self:is_truthy(identifier.valid_lexeme("a1"))
	self:is_falsy(identifier.valid_lexeme(""))
	self:is_falsy(identifier.valid_lexeme("1"))
	self:is_falsy(identifier.valid_lexeme("1a"))
	local node = identifier.new("abc")
	self:is_equal(node:kind(), identifier)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())
	self:did_invoke_pass(node.accept, node, { visit_identifier = function(_, node2) self:is_equal(node2, node) end })
end
