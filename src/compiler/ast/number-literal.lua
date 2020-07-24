local abstract_node = require("compiler.ast.abstract-node")

--- The number literal AST node.
--- @class number_literal : abstract_node
local number_literal = setmetatable({}, { __index = abstract_node })
number_literal.__index = number_literal

--- Creates a number_literal AST node.
--- @param lexeme string
--- @param position position | nil
--- @return number_literal
function number_literal.new(lexeme, position)
	return setmetatable({ lexeme = lexeme, position = position }, number_literal)
end

--- Returns whether or not the lexeme is a valid number.
--- @param lexeme string
--- @return boolean
function number_literal.valid_number(lexeme)
	return (lexeme:match("^%d+$") or lexeme:match("^%d+%.%d+$")) ~= nil
end

--- Returns whether or not the node is an expression.
--- @return boolean
function number_literal:is_expression()
	return true
end

--- Accepts a visitor.
--- @param visitor abstract_visitor
function number_literal:accept(visitor)
	visitor:visit_number_literal(self)
end

return number_literal
