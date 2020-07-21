local abstract_node = require("compiler.ast.abstract-node")

--- The unary expression AST node.
--- @class unary_expression : abstract_node
local unary_expression = setmetatable({}, { __index = abstract_node })
unary_expression.__index = unary_expression

--- Creates a unary_expression AST node.
--- @param operand expression
--- @param operator string
--- @param region region | nil
--- @return unary_expression
function unary_expression.new(operand, operator, region)
	return setmetatable({ operand = operand, operator = operator, region = region }, unary_expression)
end

--- Returns whether or not the operator is a valid unary operator.
--- @param operator string
--- @return boolean
function unary_expression.valid_operator(operator)
	return operator:match("^[%-%$]$") ~= nil
end

--- Returns whether or not the node is an expression.
--- @return boolean
function unary_expression:is_expression()
	return true
end

--- Accepts a visitor.
--- @param visitor abstract_visitor
function unary_expression:accept(visitor)
	visitor:visit_unary_expression(self)
end

return unary_expression
