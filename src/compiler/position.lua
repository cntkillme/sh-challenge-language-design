--- Describes a point in a source file.
--- @class position
local position = {}

--- Creates a position
--- @return position
function position.new(line, column)
	return {
		line = line,
		column = column
	}
end

return position
