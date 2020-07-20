local symbol_table = require("compiler.symbol-table")

--- @param self test_suite
return function(self)
	local st = symbol_table.new()
	local id1 = {}
	st:bind_symbol("abc", id1)
	self:is_truthy(st:symbol("abc"))
	self:is_falsy(st:symbol("def"))
	self:is_equal((st:symbol("abc") or {}).node, id1)
	self:is_falsy((st:symbol("abc") or { previous = true }).previous)
	st:open_scope()
	self:is_truthy(st:symbol("abc"))
	self:is_equal((st:symbol("abc") or {}).node, id1)
	self:is_falsy(st:symbol("abc", 0))
	local id2 = {}
	st:bind_symbol("abc", id2)
	self:is_truthy(st:symbol("abc", 0))
	self:is_equal((st:symbol("abc") or {}).node, id2)
	st:close_scope()
	self:is_truthy(st:symbol("abc"))
	self:is_equal((st:symbol("abc") or {}).node, id1)
	self:is_falsy((st:symbol("abc") or { previous = true }).previous)
end
