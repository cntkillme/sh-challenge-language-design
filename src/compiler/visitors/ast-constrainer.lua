local diagnostic = require("compiler.diagnostic")
local symbol_table = require("compiler.symbol-table")
local function_definition = require("compiler.ast.function-definition")
local variable_definition = require("compiler.ast.variable-definition")

--- AST constrainer visitor class.
--- @class ast_constrainer
local ast_constrainer = {}
ast_constrainer.__index = ast_constrainer

--- Creates an ast_constrainer visitor.
--- @return ast_constrainer
function ast_constrainer.new()
	return setmetatable({
		_diagnostics = {},
		_symbol_table = symbol_table.new(),
		_in_expression = false
	}, ast_constrainer)
end

--- Returns the list of diagnostics.
--- @return diagnostic[]
function ast_constrainer:diagnostics()
	return self._diagnostics
end

--- Visitor for a program AST node.
--- @param node program
function ast_constrainer:visit_program(node)
	for _, stmt in ipairs(node.statements) do
		stmt:accept(self)
	end

	node.returns:accept(self)
end

--- Visitor for a function_definition AST node.
--- @param node function_definition
function ast_constrainer:visit_function_definition(node)
	if self._symbol_table:symbol(node.name.lexeme, 0) then
		table.insert(self._diagnostics, diagnostic.new("duplicate identifier", node.origin))
	end

	self._symbol_table:open_scope()

	for _, param in ipairs(node.parameters) do
		if self._symbol_table:symbol(param.lexeme, 0) then
			table.insert(self._diagnostics, diagnostic.new("duplicate parameter", param.origin))
		end

		param.symbol = self._symbol_table:bind_symbol(param.lexeme, param)
	end

	self._in_expression = true
	node.body:accept(self)
	self._in_expression = false
	self._symbol_table:close_scope()

	-- The symbol is binded after the body is traversed to prohibit recursion.
	node.symbol = self._symbol_table:bind_symbol(node.name.lexeme, node)
end

--- Visitor for a variable_definition AST node.
--- @param node variable_definition
function ast_constrainer:visit_variable_definition(node)
	if self._symbol_table:symbol(node.name.lexeme, 0) then
		table.insert(self._diagnostics, diagnostic.new("duplicate identifier", node.origin))
	end

	if node.expression then
		self._in_expression = true
		node.expression:accept(self)
		self._in_expression = false
	end

	-- The symbol is binded after the expression is traversed to prohibit "self-referencing".
	node.symbol = self._symbol_table:bind_symbol(node.name.lexeme, node)
end

--- Visitor for a variable_assignment AST node.
--- @param node variable_assignment
function ast_constrainer:visit_variable_assignment(node)
	node.target:accept(self)

	if node.target.symbol and node.target.symbol.node:kind() ~= variable_definition then
		table.insert(self._diagnostics, diagnostic.new("attempt to assign to a function", node.origin))
	end

	self._in_expression = true
	node.expression:accept(self)
	self._in_expression = false
end

--- Visitor for a binary_expression AST node.
--- @param node binary_expression
function ast_constrainer:visit_binary_expression(node)
	node.left_operand:accept(self)
	node.right_operand:accept(self)
end

--- Visitor for a unary_expression AST node.
--- @param node unary_expression
function ast_constrainer:visit_unary_expression(node)
	node.operand:accept(self)
end

--- Visitor for a call_expression AST node.
--- @param node call_expression
function ast_constrainer:visit_call_expression(node)
	self._in_expression = false
	node.target:accept(self)
	self._in_expression = true

	if node.target.symbol then
		if node.target.symbol.node:kind() ~= function_definition then
			table.insert(self._diagnostics, diagnostic.new("attempt to call a variable", node.origin))
		else
			if #node.arguments ~= #node.target.symbol.node.parameters then
				table.insert(self._diagnostics, diagnostic.new("argument count differs from parameter count", node.origin))
			end
		end
	end

	self._in_expression = true

	for _, argument in ipairs(node.arguments) do
		argument:accept(self)
	end

	self._in_expression = false
end

--- Visitor for a identifier AST node.
--- @param node identifier
function ast_constrainer:visit_identifier(node)
	node.symbol = self._symbol_table:symbol(node.lexeme)

	if not node.symbol then
		table.insert(self._diagnostics, diagnostic.new("unknown identifier", node.origin))
	elseif self._in_expression and node.symbol.node:is_statement() then
		if node.symbol.node:kind() ~= variable_definition then
			table.insert(self._diagnostics, diagnostic.new("expected expression", node.origin))
		end
	end
end

--- Visitor for a number_literal AST node.
--- @param node number_literal
function ast_constrainer:visit_number_literal(node) -- luacheck: ignore 212/node
end

return ast_constrainer
