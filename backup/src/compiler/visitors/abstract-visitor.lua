--- Abstract Visitor Class
-- @author CntKillMe

local abstract_visitor = {}
abstract_visitor.__index = abstract_visitor

function abstract_visitor.new()
	return setmetatable({}, abstract_visitor)
end

function abstract_visitor:visit_program(node)
end

function abstract_visitor:visit_variable_definition(node)
end

function abstract_visitor:visit_variable_assignment(node)
end

function abstract_visitor:visit_function_definition(node)
end

function abstract_visitor:visit_function_call(node)
end

function abstract_visitor:visit_binary_expression(node)
end

function abstract_visitor:visit_unary_expression(node)
end

function abstract_visitor:visit_input_argument(node)
end

function abstract_visitor:visit_identifier(node)
end

function abstract_visitor:visit_number(node)
end

return abstract_visitor
