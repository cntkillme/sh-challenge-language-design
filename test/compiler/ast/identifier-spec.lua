local identifier = require("compiler.ast.identifier")

--- @param self test_suite
return function(self)
	self:is_truthy(identifier.valid_identifier("a"))
	self:is_truthy(identifier.valid_identifier("ab"))
	self:is_truthy(identifier.valid_identifier("a1"))
	self:is_falsy(identifier.valid_identifier(""))
	self:is_falsy(identifier.valid_identifier("1"))
	self:is_falsy(identifier.valid_identifier("1a"))
	local node = identifier.new("abc")
	self:is_equal(node:kind(), identifier)
	self:is_falsy(node:is_statement())
	self:is_truthy(node:is_expression())
	self:did_invoke_pass(node.accept, node, { visit_identifier = function(_, node2) self:is_equal(node2, node) end })
end
