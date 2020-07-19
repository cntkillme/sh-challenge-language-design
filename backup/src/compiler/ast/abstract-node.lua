--- Abstract Node Class
-- @author CntKillMe

local utility = require("utility")
local abstract_node = {}
abstract_node.__index = abstract_node

function abstract_node.new()
	return setmetatable({
		_first_line = 0,
		_last_line = 0,
		_first_column = 0,
		_last_column = 0,
		_first_position = 0,
		_last_position = 0
	}, abstract_node)
end


function abstract_node:accept(visitor) -- @virtual
	error("abstract_node is an abstract class")
end

function abstract_node:is_statement() -- @virtual
	error("abstract_node is an abstract class")
end

function abstract_node:is_expression() -- @virtual
	error("abstract_node is an abstract class")
end

function abstract_node:copy() -- @final
	return utility.copy(self)
end

function abstract_node:type() -- @final
	return getmetatable(self)
end

function abstract_node:line() -- @final
	return self._first_line, self._last_line
end

function abstract_node:column() -- @final
	return self._first_column, self._last_column
end

function abstract_node:position() -- @final
	return self._first_position, self._last_position
end

function abstract_node:set_line(firstLine, lastLine) -- @final
	assert(type(firstLine) == "number" and firstLine % 1 == 0 and firstLine > 0 and firstLine < 2^32,
		"firstLine must be a positive integral value less than 2^32")
	assert(type(lastLine) == "number" and lastLine % 1 == 0 and lastLine > 0 and lastLine < 2^32,
		"lastLine must be a positive integral value less than 2^32")
	assert(lastLine >= firstLine,
		"lastLine must come at or after firstLine")
	self._first_line = firstLine
	self._last_line = lastLine
	return self
end

function abstract_node:set_column(firstColumn, lastColumn) -- @final
	assert(type(firstColumn) == "number" and firstColumn % 1 == 0 and firstColumn > 0 and firstColumn < 2^32,
		"firstColumn must be a positive integral value less than 2^32")
	assert(type(lastColumn) == "number" and lastColumn % 1 == 0 and lastColumn > 0 and lastColumn < 2^32,
		"lastColumn must be a positive integral value less than 2^32")
	assert(self._first_line ~= self._last_line or lastColumn >= firstColumn,
		"lastColumn must come at or after firstColumn when on the same line")
	self._first_column = firstColumn
	self._last_column = lastColumn
	return self
end

function abstract_node:set_position(firstPosition, lastPosition) -- @final
	assert(type(firstPosition) == "number" and firstPosition % 1 == 0 and firstPosition >= 0 and firstPosition < 2^32,
		"firstPosition must be a non-negative integral value less than 2^32")
	assert(type(lastPosition) == "number" and lastPosition % 1 == 0 and lastPosition >= 0 and lastPosition < 2^32,
		"lastPosition must be a non-negative integral value less than 2^32")
	assert(lastPosition >= firstPosition,
		"lastPosition must come at or after firstPosition")
	self._first_position = firstPosition
	self._last_position = lastPosition
	return self
end

return abstract_node
