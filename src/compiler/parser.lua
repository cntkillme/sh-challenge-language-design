--- Given a source file, yields an undecorated AST after syntax analysis.
--- @class parser
local parser = {}
parser.__index = parser

--- Creates a parser.
--- @param istream input_stream
--- @return parser
function parser.new(istream) -- luacheck: ignore 212/istream
	return setmetatable({
		-- implementation defined
	}, parser)
end

--- Constructs an undecorated AST from the input stream.
--- @return program
function parser:parse()
	error("parser::parse(): not yet implemented!")
end

--- Returns the list of diagnostics.
--- @return diagnostic[]
function parser:diagnostics()
	-- implementation defined
end

return parser
