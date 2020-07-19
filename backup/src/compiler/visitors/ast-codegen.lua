--- AST Code Generation Class
-- @author CntKillMe

local abstract_visitor = require("compiler.visitors.abstract-visitor")
local ast_codegen = setmetatable({}, {__index = abstract_visitor})
ast_codegen.__index = ast_codegen

function ast_codegen.new(path)
	error("not yet implemented")
end

function ast_codegen:visit_program(node)
	error("not yet implemented")
end

function ast_codegen:visit_variable_definition(node)
	error("not yet implemented")
end

function ast_codegen:visit_variable_assignment(node)
	error("not yet implemented")
end

function ast_codegen:visit_function_definition(node)
	error("not yet implemented")
end

function ast_codegen:visit_function_call(node)
	error("not yet implemented")
end

function ast_codegen:visit_binary_expression(node)
	error("not yet implemented")
end

function ast_codegen:visit_unary_expression(node)
	error("not yet implemented")
end

function abstract_visitor:visit_input_argument(node)
	error("not yet implemented")
end

function ast_codegen:visit_identifier(node)
	error("not yet implemented")
end

function ast_codegen:visit_number(node)
	error("not yet implemented")
end

return ast_codegen
