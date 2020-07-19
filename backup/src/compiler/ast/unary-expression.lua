--- Unary Expression Class
-- @author CntKillMe

local abstract_node = require("compiler.ast.abstract-node")
local unary_expression = setmetatable({}, {__index = abstract_node})
unary_expression.__index = unary_expression

function unary_expression.new(operand, operator)
	local node = setmetatable(abstract_node.new(), unary_expression)
	if operand then node:set_operand(operand) end
	if operator then node:set_operator(operator) end
	return node
end

function unary_expression.valid_operator(lexeme)
	return type(lexeme) == "string" and (lexeme == '-' or lexeme == '$')
end

function unary_expression:accept(visitor) -- @override
	return visitor:visit_unary_expression(self)
end

function unary_expression:is_statement() -- @override
	return false
end

function unary_expression:is_expression() -- @override
	return true
end

function unary_expression:operand()
	return self._operand
end

function unary_expression:operator()
	return self._operator
end

function unary_expression:set_operand(operand)
	assert(operand:is_expression(), "operand must be an expression")
	self._operand = operand
	return self
end

function unary_expression:set_operator(operator)
	assert(self.valid_operator(operator), "invalid operator")
	self._operator = operator
	return self
end

return unary_expression
