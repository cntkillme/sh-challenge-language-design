local bytecode = require("bytecode")
local diagnostic = require("compiler.diagnostic")
local function_definition = require("compiler.ast.function-definition")

--- AST codegen visitor class.
--- @class ast_codegen
local ast_codegen = {}
ast_codegen.__index = ast_codegen

--- Creates an ast_codegen visitor.
--- @return ast_codegen
function ast_codegen.new()
	return setmetatable({
		_pc = 0,
		_body = {},
		_content = {},
		_globals = {},
		_functions = {},
		_diagnostics = {},
		_in_function = false,
		_patch_table = {},
		_next_global_index = 0,
		_next_function_index = 0
	}, ast_codegen)
end

--- Returns the bytecode content.
--- @return string
function ast_codegen:content()
	return table.concat(self._content)
end

--- Returns the list of diagnostics.
--- @return diagnostic[]
function ast_codegen:diagnostics()
	return self._diagnostics
end

--- Visitor for a program AST node.
--- @param node program
function ast_codegen:visit_program(node)
	local funcDefs = {}

	-- Traverse over nodes that are not function definitions first.
	for _, stmt in ipairs(node.statements) do
		if stmt:kind() ~= function_definition then
			stmt:accept(self)
		else
			table.insert(funcDefs, stmt)
		end
	end

	node.returns:accept(self)
	self:_emit_iv(bytecode.instructions.hlt.opcode)

	-- Traverse over function definitions last.
	for _, stmt in ipairs(funcDefs) do
		stmt:accept(self)
	end

	-- Patch function calls.
	for _, patch in ipairs(self._patch_table) do
		local idx = patch.body_info.index
		local funcIdx = self._globals[patch.target]
		patch.body_info.body[idx] = string.pack("<i4", self._functions[funcIdx + 1].pc - patch.pc)
	end

	-- Emit header.
	table.insert(self._content, "SHLang-1.0")

	-- Emit instructions outside of a function first.
	table.insert(self._content, table.concat(self._body))

	-- Emit functions in order.
	for _, func in ipairs(self._functions) do
		table.insert(self._content, table.concat(func.body))
	end
end

--- Visitor for a function_definition AST node.
--- @param node function_definition
function ast_codegen:visit_function_definition(node)
	local idx = self._next_function_index

	if idx > 255 then
		return
	end

	self._current_function = self:_make_function(node)
	node.body:accept(self)
	self:_emit_iv(bytecode.instructions.ret.opcode)
	self._globals[node.name.lexeme] = idx
	table.insert(self._functions, self._current_function)
	self._current_function = nil
	self._next_function_index = idx + 1

	if idx == 255 then
		table.insert(self._diagnostics, diagnostic.new("too many functions", node.origin))
	end
end

--- Visitor for a variable_definition AST node.
--- @param node variable_definition
function ast_codegen:visit_variable_definition(node)
	local idx = self._next_global_index

	if idx > 255 then
		return
	end

	if node.expression then
		node.expression:accept(self)
	else
		self:_emit_id(bytecode.instructions.imm.opcode, 0)
	end

	self._globals[node.name.lexeme] = idx
	self._next_global_index = idx + 1

	if idx == 255 then
		table.insert(self._diagnostics, diagnostic.new("too many variables", node.origin))
	end
end

--- Visitor for a variable_assignment AST node.
--- @param node variable_assignment
function ast_codegen:visit_variable_assignment(node)
	node.expression:accept(self)
	self:_emit_ib(bytecode.instructions.rep.opcode, self._globals[node.target.lexeme])
end

--- Visitor for a binary_expression AST node.
--- @param node binary_expression
function ast_codegen:visit_binary_expression(node)
	node.left_operand:accept(self)
	node.right_operand:accept(self)

	if node.operator == "+" then
		self:_emit_iv(bytecode.instructions.add.opcode)
	elseif node.operator == "-" then
		self:_emit_iv(bytecode.instructions.sub.opcode)
	elseif node.operator == "*" then
		self:_emit_iv(bytecode.instructions.mul.opcode)
	elseif node.operator == "/" then
		self:_emit_iv(bytecode.instructions.div.opcode)
	elseif node.operator == "%" then
		self:_emit_iv(bytecode.instructions.rem.opcode)
	else
		self:_emit_iv(bytecode.instructions.exp.opcode)
	end
end

--- Visitor for a unary_expression AST node.
--- @param node unary_expression
function ast_codegen:visit_unary_expression(node)
	node.operand:accept(self)

	if node.operator == "-" then
		self:_emit_iv(bytecode.instructions.neg.opcode)
	else
		self:_emit_iv(bytecode.instructions.inp.opcode)
	end
end

--- Visitor for a call_expression AST node.
--- @param node call_expression
function ast_codegen:visit_call_expression(node)
	for _, argument in ipairs(node.arguments) do
		argument:accept(self)
	end

	self:_emit_ib(bytecode.instructions.arg.opcode, #node.arguments)
	self:_emit_iw(bytecode.instructions.inv.opcode, 0) -- will patch
	table.insert(self._patch_table, { pc = self._pc, target = node.target.lexeme, body_info = self:_body_info() })
end

--- Visitor for a identifier AST node.
--- @param node identifier
function ast_codegen:visit_identifier(node)
	local func = self._current_function

	if func then
		if func.parameters[node.lexeme] then -- param
			self:_emit_ib(bytecode.instructions.cpy.opcode, func.parameters[node.lexeme])
		else
			self:_emit_ib(bytecode.instructions.gbl.opcode, self._globals[node.lexeme])
		end
	else
		self:_emit_ib(bytecode.instructions.cpy.opcode, self._globals[node.lexeme])
	end
end

--- Visitor for a number_literal AST node.
--- @param node number_literal
function ast_codegen:visit_number_literal(node)
	self:_emit_id(bytecode.instructions.imm.opcode, tonumber(node.lexeme))
end

--- @param value integer
function ast_codegen:_emit_byte(value)
	local body = self._current_function and self._current_function.body or self._body
	table.insert(body, string.pack("B", value))
	self._pc = self._pc + 1
end

--- @param value integer
function ast_codegen:_emit_word(value)
	local body = self._current_function and self._current_function.body or self._body
	table.insert(body, string.pack("<i4", value))
	self._pc = self._pc + 4
end

--- @param value number
function ast_codegen:_emit_double(value)
	local body = self._current_function and self._current_function.body or self._body
	table.insert(body, string.pack("<d", value))
	self._pc = self._pc + 8
end


--- @param opcode integer
function ast_codegen:_emit_iv(opcode)
	self:_emit_byte(opcode)
end

--- @param opcode integer
--- @param operand integer
function ast_codegen:_emit_ib(opcode, operand)
	self:_emit_byte(opcode)
	self:_emit_byte(operand)
end

--- @param opcode integer
--- @param operand integer
function ast_codegen:_emit_iw(opcode, operand)
	self:_emit_byte(opcode)
	self:_emit_word(operand)
end

--- @param opcode integer
--- @param operand number
function ast_codegen:_emit_id(opcode, operand)
	self:_emit_byte(opcode)
	self:_emit_double(operand)
end

--- @param definition function_definition
--- @return table
function ast_codegen:_make_function(definition)
	local func = {
		pc = self._pc,
		body = {},
		parameters = {}
	}

	for idx, param in ipairs(definition.parameters) do
		func.parameters[param.lexeme] = idx - 1

		if idx == 256 then
			table.insert(self._diagnostics, diagnostic.new("too many parameters", param.origin))
			break
		end
	end

	return func
end

--- @return table
function ast_codegen:_body_info()
	local body = self._current_function and self._current_function.body or self._body

	return { body = body, index = #body }
end

return ast_codegen
