--- AST Printer Class
-- @author CntKillMe

local abstract_visitor = require("compiler.visitors.abstract-visitor")
local ast_printer = setmetatable({}, {__index = abstract_visitor})
ast_printer.__index = ast_printer

function ast_printer.new()
	return setmetatable({depth = 0}, ast_printer)
end

function ast_printer:visit_program(node)
	self:_print("program")
	self.depth = self.depth + 1

	for idx, statement in node:statements() do
		statement:accept(self)
	end

	node:expression():accept(self)
	self.depth = self.depth - 1
end

function ast_printer:visit_variable_definition(node)
	self:_print("variable_definition")
	self.depth = self.depth + 1
	node:name():accept(self)
	local value = node:value()

	if value then
		value:accept(self)
	end

	self.depth = self.depth - 1
end

function ast_printer:visit_variable_assignment(node)
	self:_print("variable_assignment")
	self.depth = self.depth + 1
	node:name():accept(self)
	node:value():accept(self)
	self.depth = self.depth - 1
end

function ast_printer:visit_function_definition(node)
	self:_print("function_definition")
	self.depth = self.depth + 1
	node:name():accept(self)

	for _, parameter in node:parameters() do
		parameter:accept(self)
	end

	assert(node:expression(), "expected expression for function definition"):accept(self)
	self.depth = self.depth - 1
end

function ast_printer:visit_function_call(node)
	self:_print("function_call")
	self.depth = self.depth + 1
	node:name():accept(self)

	for _, argument in node:arguments() do
		argument:accept(self)
	end

	self.depth = self.depth - 1
end

function ast_printer:visit_binary_expression(node)
	self:_print("binary_expression (%s)", node:operator())
	self.depth = self.depth + 1
	node:left():accept(self)
	node:right():accept(self)
	self.depth = self.depth - 1
end

function ast_printer:visit_unary_expression(node)
	self:_print("unary_expression (%s)", node:operator())
	self.depth = self.depth + 1
	node:operand():accept(self)
	self.depth = self.depth - 1
end

function ast_printer:visit_input_argument(node)
	self:_print("input_argument (%s)", node:lexeme())
end

function ast_printer:visit_identifier(node)
	self:_print("identifier (%s)", node:lexeme())
end

function ast_printer:visit_number(node)
	self:_print("number (%s)", node:lexeme())
end

function ast_printer:_print(fmt, ...)
	print(("  "):rep(self.depth) .. fmt:format(...))
end

return ast_printer
