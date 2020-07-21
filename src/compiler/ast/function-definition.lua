local region = require("compiler.region")
local abstract_node = require("compiler.ast.abstract-node")

--- The call expression AST node.
--- @class function_definition : abstract_node
local function_definition = setmetatable({}, { __index = abstract_node })
function_definition.__index = function_definition

--- Creates a new function_definition AST node.
--- @param name identifier
--- @param parameters identifier[]
--- @param body expression
--- @return function_definition
function function_definition.new(name, parameters, body)
	return setmetatable({
		name = name,
		parameters = parameters,
		body = body,
		region = region.extend(name.region, body.region)
	}, function_definition)
end

--- Returns whether or not the node is a statement.
--- @return boolean
function function_definition:is_statement()
	return true
end

--- Returns whether or not the node is an expression.
--- @return boolean
function function_definition:is_expression()
	return false
end

--- Accepts a visitor.
--- @param visitor abstract_visitor
function function_definition:accept(visitor)
	visitor:visit_function_definition(self)
end

return function_definition
