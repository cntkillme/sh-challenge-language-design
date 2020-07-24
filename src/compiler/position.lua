--- Describes a point in a source file.
--- @class position
local position = {}
local zero

--- Creates a position
--- @return position
function position.new(line, column)
	return {
		line = line,
		column = column
	}
end

--- Yields the zero position
--- @return position
function position.zero()
	return zero
end

zero = position.new(0, 0)

return position
