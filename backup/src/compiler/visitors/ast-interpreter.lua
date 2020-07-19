--- AST Interpreter Class
-- @author CntKillMe

local abstract_visitor = require("compiler.visitors.abstract-visitor")
local ast_interpreter = setmetatable({}, {__index = abstract_visitor})
ast_interpreter.__index = ast_interpreter

function ast_interpreter.new(inputs)
	return setmetatable({
		_result = nil,
		_inputs = inputs,
		_variables = {},
		_functions = {},
	}, ast_interpreter)
end

function ast_interpreter:visit_program(node)
	for _, statement in node:statements() do
		statement:accept(self)
	end

	self._result = node:expression():accept(self)
end

function ast_interpreter:visit_variable_definition(node)
	self:_register_variable(node:name(), node:value():accept(self))
end

function ast_interpreter:visit_variable_assignment(node)
	self:_set_variable(node:name(), node:value():accept(self))
end

function ast_interpreter:visit_function_definition(node)
	self:_register_function(node)
end

function ast_interpreter:visit_function_call(node)
	self:_call_function(node)

	local lexeme = node:name():lexeme()
	assert(not self._variables[lexeme], "attempt to call variable " .. lexeme)
	local func = assert(self._functions[lexeme], "unknown function " .. lexeme)
	local arguments = table.pack()

	for argument in node:arguments() do
		table.insert(arguments, argument:accept(self))
		arguments.n = arguments.n + 1
	end

	return func(table.unpack(arguments, 1, arguments.n))
end

function ast_interpreter:visit_binary_expression(node)
	local left = node:left():accept(self)
	local right = node:right():accept(self)
	local operator = node:operator()

	if operator == '+' then
		return left + right
	elseif operator == '-' then
		return left - right
	elseif operator == '*' then
		return left * right
	elseif operator == '/' then
		return left / right
	elseif operator == '^' then
		return left ^ right
	else
		error("unknown binary operator " .. operator)
	end
end

function ast_interpreter:visit_unary_expression(node)
	local operand = node:operand():accept(self)
	local operator = node:operator()

	if operand == '-' then
		self._result = -operand._result
	else
		error("unknown unary operator " .. operator)
	end
end

function ast_interpreter:visit_input_argument(node)
	self._result = self._inputs[tonumber(node.lexeme) or 0] or 0
end

function ast_interpreter:visit_identifier(node)
	self._result = self:_get_variable(node)
end

function ast_interpreter:visit_number(node)
	self._result = assert(tonumber(node:lexeme()))
end

function ast_interpreter:copy()
	local visitor = ast_interpreter.new()
	visitor._result = self._result

	for id, value in pairs(self._variables) do
		visitor._variables[id] = value
	end

	for id, node in pairs(self._functions) do
		visitor._functions[id] = node
	end

	return visitor
end

function ast_interpreter:result()
	return self._result
end

function ast_interpreter:_register_variable(id, value)
	local lexeme = id:lexeme()
	assert(not self._variables[lexeme], "redefinition of variable " .. lexeme)
	assert(not self._functions[lexeme], "redefinition of function " .. lexeme)
	self._variables[lexeme] = value and assert(tonumber(lexeme)) or 0
end

function ast_interpreter:_get_variable(id)
	local lexeme = id:lexeme()
	return assert(self._variables[lexeme], "attempt to get undefined variable " .. lexeme)
end

function ast_interpreter:_set_variable(id, value)
	local lexeme = id:lexeme()
	assert(self._variables[lexeme], "attempt to set undefined variable " .. lexeme)
	self._variables[lexeme] = assert(tonumber(value))
end

function ast_interpreter:_register_function(func)
	local lexeme = func:name():lexeme()
	assert(not (self._variables[lexeme] or self._functions[lexeme]), "redefinition of " .. lexeme)
	self._functions[lexeme] = func
end

function ast_interpreter:_get_function(id)
	local lexeme = id:lexeme()
	return assert(self._functions[lexeme], "attempt to get undefined function " .. lexeme)
end

function ast_interpreter:_call_function(id, ...)
	local func = self:_get_function(id)
	local args = table.pack(...)
	assert(args.n == func:parameter_count(),
		("argument count mismatch (%d expected, got %d)"):format(func:parameter_count(), args.n))

	-- copy vistor and set vars param names to args
	local visitor = self:copy()

	for idx, parameter in func:parameters() do
		assert(type(args[idx]) == "number", ("argument %d is not a number"):format(idx))
		visitor._variables[parameter:lexeme()] = args[idx]
		visitor._functions[parameter:lexeme()] = nil
	end

	func:expression():visit(visitor)
	return visitor._result
end

return ast_interpreter
