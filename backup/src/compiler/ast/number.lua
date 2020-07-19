--- Number Class
-- @author CntKillMe

local abstract_node = require("compiler.ast.abstract-node")
local number = setmetatable({}, {__index = abstract_node})
number.__index = number

function number.new(lexeme)
	local node = setmetatable(abstract_node.new(), number)
	if lexeme then node:set_lexeme(lexeme) end
	return node
end

function number.valid_lexeme(lexeme)
	return type(lexeme) == "string" and lexeme:find("^%d+%.?%d*$") ~= nil
end

function number:accept(visitor) -- @override
	return visitor:visit_number(self)
end

function number:is_statement() -- @override
	return false
end

function number:is_expression() -- @override
	return true
end

function number:lexeme()
	return self._lexeme
end

function number:set_lexeme(lexeme)
	assert(self.valid_lexeme(lexeme), "invalid number lexeme")
	self._lexeme = lexeme
	return self
end

return number
