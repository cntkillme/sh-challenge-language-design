--- Identifier Class
-- @author CntKillMe

local abstract_node = require("compiler.ast.abstract-node")
local identifier = setmetatable({}, {__index = abstract_node})
identifier.__index = identifier

function identifier.new(lexeme)
	local node = setmetatable(abstract_node.new(), identifier)
	if lexeme then node:set_lexeme(lexeme) end
	return node
end

function identifier.valid_lexeme(lexeme)
	return type(lexeme) == "string" and lexeme:find("^[%a_][%w_]*$") ~= nil
end

function identifier:accept(visitor) -- @override
	return visitor:visit_identifier(self)
end

function identifier:is_statement() -- @override
	return false
end

function identifier:is_expression() -- @override
	return true
end

function identifier:lexeme()
	return self._lexeme
end

function identifier:set_lexeme(lexeme)
	assert(self.valid_lexeme(lexeme), "invalid identifier lexeme")
	self._lexeme = lexeme
	return self
end

return identifier
