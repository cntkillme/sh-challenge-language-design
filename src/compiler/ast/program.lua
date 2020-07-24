local position = require("compiler.position")
local abstract_node = require("compiler.ast.abstract-node")

--- The program AST node.
--- @class program : abstract_node
local program = setmetatable({}, { __index = abstract_node })
program.__index = program

--- Creates a new program AST node.
--- @param statements statement[]
--- @param returns expression
--- @param origin position | nil
--- @return program
function program.new(statements, returns, origin)
	return setmetatable({ statements = statements, returns = returns, origin = origin or position.zero() }, program)
end

--- Returns whether or not the node is a statement.
--- @return boolean
function program:is_statement()
	return false
end

--- Returns whether or not the node is an expression.
--- @return boolean
function program:is_expression()
	return false
end

--- Accepts a visitor.
--- @param visitor abstract_visitor
function program:accept(visitor)
	visitor:visit_program(self)
end

return program
