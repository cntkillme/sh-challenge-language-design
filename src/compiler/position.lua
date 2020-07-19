--- @class position
--- @field public first_line number
--- @field public last_line number
--- @field public first_column number
--- @field public last_column number
--- @field public first_position number
--- @field public last_position number
local position = {}

--- Creates an identity position.
--- @return position
function position.identity()
	return {
		first_line = 1,
		last_line = 1,
		first_column = 1,
		last_column = 1,
		first_position = 0,
		last_position = 0
	}
end

function position.fromLexeme(lexeme, first_line, first_column, first_position)
	local lines = select(2, lexeme:gsub("\n", "\n"))
	local lastColumn = #lexeme:match("([^\n]*)$")

	assert(
		lexeme:sub(1, 1) ~= "\n" and lastColumn ~= 0,
		"position::fromLexeme(): lexeme cannot be empty or start or end with a line feed!"
	)

	return {
		first_line = first_line,
		last_line = first_line + lines,
		first_column = first_column,
		last_column = lines == 0 and first_column + lastColumn or lastColumn,
		first_position = first_position,
		last_position = first_position + #lexeme
	}
end

return position
