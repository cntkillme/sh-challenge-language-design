local output_stream = require("output-stream")

local function test_output_stream_pass(self, ostream, written)
	local line = 1
	local column = 1
	local position = 0
	self:is_equal(ostream:line(), line)
	self:is_equal(ostream:column(), column)
	self:is_equal(ostream:position(), position)
	ostream:write(written)
	ostream:flush()

	for char in written:gmatch(".") do
		if char == "\n" then
			line = line + 1
			column = 1
		else
			column = column + 1
		end

		position = position + 1
	end

	self:is_equal(ostream:line(), line)
	self:is_equal(ostream:column(), column)
	self:is_equal(ostream:position(), position)
	self:did_invoke_fail(ostream.error, ostream, "some error message")
	ostream:close()
end

local function test_output_stream_pass_binary(self, ostream, written)
	self:is_equal(ostream:line(), 0)
	self:is_equal(ostream:column(), 0)
	self:is_equal(ostream:position(), 0)
	ostream:write(written)
	ostream:flush()
	self:is_equal(ostream:line(), 0)
	self:is_equal(ostream:column(), 0)
	self:is_equal(ostream:position(), #written)
	self:did_invoke_fail(ostream.error, ostream, "some error message")
	ostream:close()
end

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
	test_output_stream_pass(
		self,
		output_stream.fromFile("resources/output-stream/pass.txt"),
		read_file("resources/output-stream/pass.txt")
	)

	test_output_stream_pass_binary(
		self,
		output_stream.fromFile("resources/output-stream/pass-binary.txt", true),
		read_file("resources/output-stream/pass-binary.txt", true)
	)

	local buffer1 =
		"\n\t !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n"
	local buffer2 = "\n\t123456\n\t\n"

	do
		-- redirect stdout
		local stdout = io.stdout
		io.stdout = io.tmpfile() -- luacheck: ignore
		test_output_stream_pass(self, output_stream.fromStdout(), buffer1)
		test_output_stream_pass_binary(self, output_stream.fromStdout(true), buffer2)
		io.stdout = stdout  -- luacheck: ignore
	end

	local ostream = output_stream.fromFile("resources/output-stream/fail.txt")
	self:did_invoke_fail(ostream.write, ostream, "\1\2")
	ostream:close()
end
