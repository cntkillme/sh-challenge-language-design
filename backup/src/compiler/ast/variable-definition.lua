--- Variable Definition Class
-- @author CntKillMe

local abstract_node = require("compiler.ast.abstract-node")
local identifier = require("compiler.ast.identifier")
local variable_definition = setmetatable({}, {__index=abstract_node})
variable_definition.__index = variable_definition

function variable_definition.new(name, value)
	local node = setmetatable(abstract_node.new(), variable_definition)
	if name then node:set_name(name) end
	if value then node:set_value(value) end
	return node
end

function variable_definition:accept(visitor) -- @override
	return visitor:visit_variable_definition(self)
end

function variable_definition:is_statement() -- @override
	return true
end

function variable_definition:is_expression() -- @override
	return false
end

function variable_definition:name()
	return self._name
end

function variable_definition:value()
	return self._value
end

function variable_definition:set_name(name)
	assert(name:type() == identifier, "name must be an identifier")
	self._name = name
	return self
end

function variable_definition:set_value(value)
	assert(value:is_expression(), "value must be an expression")
	self._value = value
	return self
end

return variable_definition
