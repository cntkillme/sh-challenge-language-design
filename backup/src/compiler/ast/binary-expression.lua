--- Binary Expression Class
-- @author CntKillMe

local abstract_node = require("compiler.ast.abstract-node")
local binary_expression = setmetatable({}, {__index = abstract_node})
binary_expression.__index = binary_expression

function binary_expression.new(left, right, operator)
	local node = setmetatable(abstract_node.new(), binary_expression)
	if left then node:set_left(left) end
	if right then node:set_right(right) end
	if operator then node:set_operator(operator) end
	return node
end

function binary_expression.valid_operator(lexeme)
	return type(lexeme) == "string" and lexeme:find("^[%+%-%*%/%^]$") ~= nil
end

function binary_expression:accept(visitor) -- @override
	return visitor:visit_binary_expression(self)
end

function binary_expression:is_statement() -- @override
	return false
end

function binary_expression:is_expression() -- @override
	return true
end

function binary_expression:left()
	return self._left
end

function binary_expression:right()
	return self._right
end

function binary_expression:operator()
	return self._operator
end

function binary_expression:set_left(left)
	assert(left:is_expression(), "left must be an expression")
	self._left = left
	return self
end

function binary_expression:set_right(right)
	assert(right:is_expression(), "right must be an expression")
	self._right = right
	return self
end

function binary_expression:set_operator(operator)
	assert(self.valid_operator(operator), "invalid operator")
	self._operator = operator
	return self
end

return binary_expression
