--- A region defines the area bounding a lexeme. Regions hold the following invariants:
---  - regions are not empty (their bounds are inclusive),
---  - first_line <= last_line,
---  - first_position <= last_position,
---  - and first_column <= last_column if first_line == last_line.
--- @class region
--- @field public first_line number
--- @field public last_line number
--- @field public first_column number
--- @field public last_column number
--- @field public first_position number
--- @field public last_position number
local region = {}

--- Creates an identity region.
--- @return region
function region.identity()
	return {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 1,
		first_position = 0,
		last_position = 0
	}
end

--- Creates a region from a lexeme and an origin. The lexeme cannot be empty or end with a line feed.
--- @param lexeme string
--- @param first_line number | nil
--- @param first_column number | nil
--- @param first_position number | nil
--- @return region
function region.from_lexeme(lexeme, first_line, first_column, first_position)
	local lines = select(2, lexeme:gsub("\n", "\n"))
	local finalColSize = #lexeme:match("([^\n]*)$")
	first_line = first_line or 1
	first_column = first_column or 1
	first_position = first_position or 0
	assert(finalColSize ~= 0, "region::from_lexeme(): lexeme cannot be empty or end with a line feed!")

	return {
		first_line = first_line,
		last_line = first_line + lines,
		first_column = first_column,
		last_column = lines == 0 and first_column + finalColSize - 1 or finalColSize,
		first_position = first_position,
		last_position = first_position + #lexeme - 1
	}
end

--- Creates a new region encapsulating the given regions.
--- @param region1 region
--- @param region2 region
--- @return region
function region.extend(region1, region2)
	local extendsLeft = region1.first_position > region2.last_position

	return {
		first_line = math.min(region1.first_line, region2.first_line),
		last_line = math.max(region1.last_line, region2.last_line),
		first_column = extendsLeft and region2.first_column or region1.first_column,
		last_column = extendsLeft and region1.last_column or region2.last_column,
		first_position = math.min(region1.first_position, region2.first_position),
		last_position = math.max(region1.last_position, region2.last_position)
	}
end

--- Creates a region transformed left by a transform.
--- @param origin region
--- @param transform region
--- @return region
function region.transform_left(origin, transform)
	local lineDiff = transform.last_line - transform.first_line
	local colDiff = transform.last_column - transform.first_column + 1
	local posDiff = transform.last_position - transform.first_position + 1

	return {
		first_line = origin.first_line - lineDiff,
		last_line = origin.last_line,
		first_column = lineDiff == 0 and origin.first_column - colDiff or transform.first_column,
		last_column = origin.last_column,
		first_position = origin.first_position - posDiff,
		last_position = origin.last_position
	}
end

--- Creates a region transformed right by a transform.
--- @param origin region
--- @param transform region
--- @return region
function region.transform_right(origin, transform)
	local lineDiff = transform.last_line - transform.first_line
	local colDiff = transform.last_column - transform.first_column + 1
	local posDiff = transform.last_position - transform.first_position + 1

	return {
		first_line = origin.first_line,
		last_line = origin.last_line + lineDiff,
		first_column = origin.first_column,
		last_column = lineDiff == 0 and origin.last_column + colDiff or transform.last_column,
		first_position = origin.first_position,
		last_position = origin.last_position + posDiff
	}
end

return region
