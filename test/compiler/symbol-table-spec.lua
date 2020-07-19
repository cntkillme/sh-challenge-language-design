local symbol_table = require("compiler.symbol-table")

--- @param self test_suite
return function(self)
	local st = symbol_table.new()
	local id1 = {}
	st:bind_identifier("abc", id1)
	self:is_truthy(st:get_binder("abc"))
	self:is_falsy(st:get_binder("def"))
	self:is_equal((st:get_binder("abc") or {}).node, id1)
	self:is_falsy((st:get_binder("abc") or { previous = true }).previous)
	st:open_scope()
	self:is_truthy(st:get_binder("abc"))
	self:is_equal((st:get_binder("abc") or {}).node, id1)
	self:is_falsy(st:get_binder("abc", 0))
	local id2 = {}
	st:bind_identifier("abc", id2)
	self:is_truthy(st:get_binder("abc", 0))
	self:is_equal((st:get_binder("abc") or {}).node, id2)
	st:close_scope()
	self:is_truthy(st:get_binder("abc"))
	self:is_equal((st:get_binder("abc") or {}).node, id1)
	self:is_falsy((st:get_binder("abc") or { previous = true }).previous)
end
