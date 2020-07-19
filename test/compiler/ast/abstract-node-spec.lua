local position = require("compiler.position")
local abstract_node = require("compiler.ast.abstract-node")

--- @param self test_suite
return function(self)
	local node = setmetatable({ position = position.identity() }, abstract_node)
	self:is_equal(node:kind(), abstract_node)
	self:is_falsy(node:is_statement())
	self:is_falsy(node:is_expression())
	self:did_invoke_fail(node.accept, node, {})
end
