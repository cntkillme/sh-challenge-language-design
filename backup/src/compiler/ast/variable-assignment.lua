--- Variable Assignment Class
-- @author CntKillMe

local abstract_node = require("compiler.ast.abstract-node")
local identifier = require("compiler.ast.identifier")
local variable_assignment = setmetatable({}, {__index = abstract_node})
variable_assignment.__index = variable_assignment

function variable_assignment.new(name, value)
	local node = setmetatable(abstract_node.new(), variable_assignment)
	if name then node:set_name(name) end
	if value then node:set_value(value) end
	return node
end

function variable_assignment:accept(visitor) -- @override
	return visitor:visit_variable_assignment(self)
end

function variable_assignment:is_statement() -- @override
	return true
end

function variable_assignment:is_expression() -- @override
	return false
end

function variable_assignment:name()
	return self._name
end

function variable_assignment:value()
	return self._value
end

function variable_assignment:set_name(name)
	assert(name:type() == identifier, "name must be an identifier")
	self._name = name
	return self
end

function variable_assignment:set_value(value)
	assert(value:is_expression(), "value must be an expression")
	self._value = value
	return self
end

return variable_assignment
