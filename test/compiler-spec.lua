local compiler = require("compiler")
local input_stream = require("input-stream")
local output_stream = require("output-stream")

local function read_file(path, binary)
	local file = assert(io.open(path, binary and "rb" or "r"))
	local contents = {}

	while true do
		local read = assert(file:read("a"))

		if #read > 0 then
			table.insert(contents, read)
		else
			break
		end
	end

	return table.concat(contents)
end

--- @param self test_suite
return function(self)
	local expected = read_file("resources/compiler/test.bin", true)
	local output = io.tmpfile()
	compiler(input_stream.new("resources/compiler/test.txt"), output_stream.from_file(output))
	output:seek("set", 0)
	local got = read_file(output)
	self:is_equal(got, expected)
end
