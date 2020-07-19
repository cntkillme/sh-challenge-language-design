--- Function Call Class
-- @author CntKillMe

local abstract_node = require("compiler.ast.abstract-node")
local identifier = require("compiler.ast.identifier")
local function_call = setmetatable({}, {__index = abstract_node})
function_call.__index = function_call

function function_call.new(name, arguments)
	local node = setmetatable(abstract_node.new(), function_call)
	if name then node:set_name(name) end
	node._arguments = {}

	if arguments then
		for _, arg in ipairs(arguments) do
			node:add_argument(arg)
		end
	end

	return node
end

function function_call:accept(visitor) -- @override
	return visitor:visit_function_call(self)
end

function function_call:is_statement() -- @override
	return true
end

function function_call:is_expression() -- @override
	return true
end

function function_call:name()
	return self._name
end

function function_call:arguments()
	return ipairs(self._arguments)
end

function function_call:argument_count()
	return #self._arguments
end

function function_call:add_argument(arg)
	assert(arg:is_expression(), "arg must be an expression")
	table.insert(self._arguments, arg)
end

function function_call:set_name(name)
	assert(name:type() == identifier, "name must be an identifier")
	self._name = name
	return self
end

return function_call
