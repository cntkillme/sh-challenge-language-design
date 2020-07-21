--- Abstract AST visitor class.
--- @class abstract_visitor
local abstract_visitor = {}
abstract_visitor.__index = abstract_visitor

--- Visitor for a program AST node.
--- @param node program
function abstract_visitor:visit_program(node) -- luacheck: ignore 212/node
	error("abstract_visitor::visit_program(): abstract_visitor is abstract!")
end

--- Visitor for a function_definition AST node.
--- @param node function_definition
function abstract_visitor:visit_function_definition(node) -- luacheck: ignore 212/node
	error("abstract_visitor::visit_function_definition(): abstract_visitor is abstract!")
end

--- Visitor for a variable_definition AST node.
--- @param node variable_definition
function abstract_visitor:visit_variable_definition(node) -- luacheck: ignore 212/node
	error("abstract_visitor::visit_variable_definition(): abstract_visitor is abstract!")
end

--- Visitor for a variable_assignment AST node.
--- @param node variable_assignment
function abstract_visitor:visit_variable_assignment(node) -- luacheck: ignore 212/node
	error("abstract_visitor::visit_variable_assignment(): abstract_visitor is abstract!")
end

--- Visitor for a binary_expression AST node.
--- @param node binary_expression
function abstract_visitor:visit_binary_expression(node) -- luacheck: ignore 212/node
	error("abstract_visitor::visit_binary_expression(): abstract_visitor is abstract!")
end

--- Visitor for a unary_expression AST node.
--- @param node unary_expression
function abstract_visitor:visit_unary_expression(node) -- luacheck: ignore 212/node
	error("abstract_visitor::visit_unary_expression(): abstract_visitor is abstract!")
end

--- Visitor for a call_expression AST node.
--- @param node call_expression
function abstract_visitor:visit_call_expression(node) -- luacheck: ignore 212/node
	error("abstract_visitor::visit_call_expression(): abstract_visitor is abstract!")
end

--- Visitor for a identifier AST node.
--- @param node identifier
function abstract_visitor:visit_identifier(node) -- luacheck: ignore 212/node
	error("abstract_visitor::visit_identifier(): abstract_visitor is abstract!")
end

--- Visitor for a number_literal AST node.
--- @param node number_literal
function abstract_visitor:visit_number_literal(node) -- luacheck: ignore 212/node
	error("abstract_visitor::visit_number_literal(): abstract_visitor is abstract!")
end

return abstract_visitor
