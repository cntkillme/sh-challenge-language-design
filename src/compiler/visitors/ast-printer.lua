--- AST printer class.
--- @class ast_printer
local ast_printer = {}
ast_printer.__index = ast_printer

--- Creates an ast_printer visitor.
--- @param addParentheses boolean | nil
--- @return ast_printer
function ast_printer.new(addParentheses)
	return setmetatable({ _content = {}, _add_parentheses = addParentheses == true }, ast_printer)
end

--- Returns the content.
--- @return string
function ast_printer:content()
	return table.concat(self._content)
end

--- Visitor for a program AST node.
--- @param node program
function ast_printer:visit_program(node)
	for _, stmt in ipairs(node.statements) do
		stmt:accept(self)
	end

	self:_write("\nreturn ")
	node.returns:accept(self)
	self:_print()
end

--- Visitor for a function_definition AST node.
--- @param node function_definition
function ast_printer:visit_function_definition(node)
	self:_write("let ")
	node.name:accept(self)
	self:_write("(")

	for idx, param in ipairs(node.parameters) do
		param:accept(self)

		if idx < #node.parameters then
			self:_write(", ")
		end
	end

	self:_write(") = ")
	node.body:accept(self)
	self:_print()
end

--- Visitor for a variable_definition AST node.
--- @param node variable_definition
function ast_printer:visit_variable_definition(node)
	self:_write("let ")
	node.name:accept(self)

	if node.expression then
		self:_write(" = ")
		node.expression:accept(self)
	end

	self:_print()
end

--- Visitor for a variable_assignment AST node.
--- @param node variable_assignment
function ast_printer:visit_variable_assignment(node)
	node.target:accept(self)
	self:_write(" = ")
	node.expression:accept(self)
	self:_print()
end

--- Visitor for a binary_expression AST node.
--- @param node binary_expression
function ast_printer:visit_binary_expression(node)
	if self._add_parentheses then
		self:_write("(")
	end

	node.left_operand:accept(self)
	self:_write(" " .. node.operator .. " ")
	node.right_operand:accept(self)

	if self._add_parentheses then
		self:_write(")")
	end
end

--- Visitor for a unary_expression AST node.
--- @param node unary_expression
function ast_printer:visit_unary_expression(node)
	self:_write(node.operator)
	node.operand:accept(self)

end

--- Visitor for a call_expression AST node.
--- @param node call_expression
function ast_printer:visit_call_expression(node)
	node.target:accept(self)
	self:_write("(")

	for idx, param in ipairs(node.arguments) do
		param:accept(self)

		if idx < #node.arguments then
			self:_write(", ")
		end
	end

	self:_write(")")
end

--- Visitor for a identifier AST node.
--- @param node identifier
function ast_printer:visit_identifier(node)
	self:_write(node.lexeme)
end

--- Visitor for a number_literal AST node.
--- @param node number_literal
function ast_printer:visit_number_literal(node)
	self:_write(node.lexeme)
end

--- @param str string
function ast_printer:_write(str)
	table.insert(self._content, str)
end

--- @param str string
function ast_printer:_print(str)
	self:_write((str or "") .. "\n")
end

return ast_printer
