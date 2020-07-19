--- Keeps track of accessible identifiers and their parents.
--- @class symbol_table
local symbol_table = {}
symbol_table.__index = symbol_table

--- Creates a symbol_table.
--- @return symbol_table
function symbol_table.new()
	return setmetatable({
		_binders = {},
		_previous = nil
	}, symbol_table)
end

--- Opens a new scope.
function symbol_table:open_scope()
	local st = symbol_table.new()
	st._binders = self._binders
	st._previous = self._previous
	self._binders = {}
	self._previous = st
end

--- Closes the current scope.
function symbol_table:close_scope()
	assert(self._previous, "symbol_table::close_scope(): no parent scope!")
	self._binders, self._previous = self._previous._binders, self._previous._previous
end

function symbol_table:bind_identifier(name, node)
	assert(not self._binders[name], "symbol_table::bind_identifier(): identifier " .. name .. " already binded!")
	self._binders[name] = { node = node, previous = self._previous and self._previous[name] or nil }
end

--- Returns the binder by the given name.
--- @param name string
--- @param depth integer | nil
--- @return binder
function symbol_table:get_binder(name, depth)
	local binder = self._binders[name]
	depth = depth or math.huge

	if not binder and self._previous and depth > 0 then
		return self._previous:get_binder(name, depth - 1)
	end

	return binder
end

--- @class binder
--- @field node abstract_node
--- @field previous binder | nil

return symbol_table
