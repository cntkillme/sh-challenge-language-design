local abstract_node = require("compiler.ast.abstract-node")

--- The variable definition AST node.
--- @class variable_definition : abstract_node
local variable_definition = setmetatable({}, { __index = abstract_node })
variable_definition.__index = variable_definition

--- Creates a variable_definition AST node.
--- @param name identifier
--- @param expression expression | nil
--- @param position position | nil
--- @return variable_definition
function variable_definition.new(name, expression, position)
	return setmetatable({ name = name, expression = expression, position = position }, variable_definition)
end

--- Returns whether or not the node is a statement.
--- @return boolean
function variable_definition:is_statement()
	return true
end

--- Returns whether or not the node is an expression.
--- @return boolean
function variable_definition:is_expression()
	return false
end

--- Accepts a visitor.
--- @param visitor abstract_visitor
function variable_definition:accept(visitor)
	visitor:visit_variable_definition(self)
end

return variable_definition
