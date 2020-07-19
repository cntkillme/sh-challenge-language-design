--- Parser Class
-- @author <your name>

local program = require("compiler.ast.program")

local parser = {}
parser.__index = parser

function parser.new(path)
	return setmetatable({
		-- @implement additional instance fields if necessary
	}, parser)
end

function parser:parse()
	local node = program.new()

	-- @implement

	return node
end

-- @implement additional methods, static fields, and/or static methods if necessary

return parser
