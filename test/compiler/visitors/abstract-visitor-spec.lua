local abstract_visitor = require("compiler.visitors.abstract-visitor")

--- @param self test_suite
return function(self)
	local node = setmetatable({ }, abstract_visitor)
	self:did_invoke_fail(node.visit_program, node, {})
	self:did_invoke_fail(node.visit_function_definition, node, {})
	self:did_invoke_fail(node.visit_variable_definition, node, {})
	self:did_invoke_fail(node.visit_variable_assignment, node, {})
	self:did_invoke_fail(node.visit_binary_expression, node, {})
	self:did_invoke_fail(node.visit_unary_expression, node, {})
	self:did_invoke_fail(node.visit_call_expression, node, {})
	self:did_invoke_fail(node.visit_identifier, node, {})
	self:did_invoke_fail(node.visit_number_literal, node, {})
end
