local position = require("compiler.position")
local abstract_node = require("compiler.ast.abstract-node")

--- The variable assignment AST node.
--- @class variable_assignment : abstract_node
local variable_assignment = setmetatable({}, { __index = abstract_node })
variable_assignment.__index = variable_assignment

--- Creates a variable_assignment AST node.
--- @param target identifier
--- @param expression expression
--- @param origin position | nil
--- @return variable_assignment
function variable_assignment.new(target, expression, origin)
	return setmetatable({
		target = target,
		expression = expression,
		origin = origin or position.zero()
	}, variable_assignment)
end

--- Returns whether or not the node is a statement.
--- @return boolean
function variable_assignment:is_statement()
	return true
end

--- Returns whether or not the node is an expression.
--- @return boolean
function variable_assignment:is_expression()
	return false
end

--- Accepts a visitor.
--- @param visitor abstract_visitor
function variable_assignment:accept(visitor)
	visitor:visit_variable_assignment(self)
end

return variable_assignment
