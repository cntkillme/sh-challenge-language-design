local abstract_node = require("compiler.ast.abstract-node")

--- The binary expression AST node.
--- @class binary_expression : abstract_node
local binary_expression = setmetatable({}, { __index = abstract_node })
binary_expression.__index = binary_expression

--- Creates a binary_expression AST node.
--- @param leftOperand expression
--- @param rightOperand expression
--- @param operator string
--- @param region region | nil
--- @return binary_expression
function binary_expression.new(leftOperand, rightOperand, operator, region)
	return setmetatable({
		left_operand = leftOperand,
		right_operand = rightOperand,
		operator = operator,
		region = region
	}, binary_expression)
end

--- Returns whether or not the operator is a valid binary operator.
--- @param operator string
--- @return boolean
function binary_expression.valid_operator(operator)
	return operator:match("^[%+%-%*%/%%%^]$") ~= nil
end

--- Returns whether or not the node is an expression.
--- @return boolean
function binary_expression:is_expression()
	return true
end

--- Accepts a visitor.
--- @param visitor abstract_visitor
function binary_expression:accept(visitor)
	visitor:visit_binary_expression(self)
end

return binary_expression
