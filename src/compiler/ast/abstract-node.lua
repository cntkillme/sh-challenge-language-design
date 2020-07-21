--- TODO: remove the following aliases:
--- @alias abstract_visitor any

--- @alias statement variable_definition | function_definition | variable_assignment
--- @alias expression binary_expression | unary_expression | call_expression | identifier | number_literal

--- Abstract AST node class.
--- @class abstract_node
--- @field public region region
local abstract_node = {}
abstract_node.__index = abstract_node

--- Returns the node kind.
--- @return table
function abstract_node:kind()
	return getmetatable(self)
end

--- Returns whether or not the node is a statement.
--- @return boolean
function abstract_node:is_statement()
	return false
end

--- Returns whether or not the node is an expression.
--- @return boolean
function abstract_node:is_expression()
	return false
end

--- Accepts a visitor.
--- @param visitor abstract_visitor
function abstract_node:accept(visitor) -- luacheck: ignore 212/visitor
	error("abstract_node::accept(): abstract_node is abstract!")
end

return abstract_node
