--- Function Definition Class
-- @author CntKillMe

local abstract_node = require("compiler.ast.abstract-node")
local identifier = require("compiler.ast.identifier")
local function_definition = setmetatable({}, {__index=abstract_node})
function_definition.__index = function_definition

function function_definition.new(name, parameters, expression)
	local node = setmetatable(abstract_node.new(), function_definition)
	if name then node:set_name(name) end
	node._parameters = {}

	if parameters then
		for _, param in ipairs(parameters) do
			node:add_parameter(param)
		end
	end

	if expression then node:set_expression(expression) end
	return node
end

function function_definition:accept(visitor) -- @override
	return visitor:visit_function_definition(self)
end

function function_definition:is_statement() -- @override
	return true
end

function function_definition:is_expression() -- @override
	return false
end

function function_definition:name()
	return self._name
end

function function_definition:parameters()
	return ipairs(self._parameters)
end

function function_definition:expression()
	return self._expression
end

function function_definition:parameter_count()
	return #self._parameters
end

function function_definition:has_parameter(lexeme)
	assert(identifier.valid_lexeme(lexeme), "invalid parameter lexeme")

	for _, param in self:parameters() do
		if param:lexeme() == lexeme then
			return true
		end
	end

	return false
end

function function_definition:add_parameter(name)
	assert(name:type() == identifier, "name must be an identifier")
	assert(not self:has_parameter(name:lexeme()), "duplicate parameter")
	table.insert(self._parameters, name)
end

function function_definition:set_expression(expr)
	assert(expr:is_expression(), "expr must be an expression")
	self._expression = expr
end

return function_definition
