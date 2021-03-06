local position = require("compiler.position")
local abstract_node = require("compiler.ast.abstract-node")

--- The identifier AST node.
--- @class identifier : abstract_node
local identifier = setmetatable({}, { __index = abstract_node })
identifier.__index = identifier

--- Creates a new identifier AST node.
--- @param lexeme string
--- @param origin position | nil
--- @return identifier
function identifier.new(lexeme, origin)
	return setmetatable({
		--- @type symbol | nil
		symbol = nil,
		lexeme = lexeme,
		origin = origin or position.zero()
	}, identifier)
end

--- Returns whether or not the lexeme is a valid identifier name.
--- @param lexeme string
--- @return boolean
function identifier.valid_identifier(lexeme)
	return lexeme:match("^%a%w*$") ~= nil
end

--- Returns whether or not the node is an expression.
--- @return boolean
function identifier:is_expression()
	return true
end

--- Accepts a visitor.
--- @param visitor abstract_visitor
function identifier:accept(visitor)
	visitor:visit_identifier(self)
end

return identifier
