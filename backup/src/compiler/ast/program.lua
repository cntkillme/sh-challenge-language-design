--- Program Class
-- @author CntKillMe

local abstract_node = require("compiler.ast.abstract-node")
local program = setmetatable({}, {__index = abstract_node})
program.__index = program

function program.new(stmts, expr)
	local node = setmetatable(abstract_node.new(), program)
	node._statements = {}

	if stmts then
		for _, stmt in ipairs(stmts) do
			node:add_statement(stmt)
		end
	end

	if expr then node:set_expression(expr) end
	return node
end

function program:accept(visitor) -- @override
	return visitor:visit_program(self)
end

function program:is_statement() -- @override
	return false
end

function program:is_expression() -- @override
	return false
end

function program:statements()
	return ipairs(self._statements)
end

function program:expression()
	return self._expression
end

function program:statement_count()
	return #self._statements
end

function program:add_statement(stmt)
	assert(stmt:is_statement(), "stmt must be a statement")
	table.insert(self._statements, stmt)
end

function program:set_expression(expr)
	assert(expr:is_expression(), "expr must be an expression")
	self._expression = expr
	return self
end

return program
