local input_stream = require("input-stream")

local function test_input_stream_pass(self, istream, expected)
	local line = 1
	local column = 1
	local position = 0
	local charactersRead = {}
	self:is_equal(istream:line(), line)
	self:is_equal(istream:column(), column)
	self:is_equal(istream:position(), position)

	for char in expected:gmatch(".") do
		table.insert(charactersRead, istream:get())

		if char == "\n" then
			line = line + 1
			column = 1
		else
			column = column + 1
		end

		position = position + 1
	end

	self:is_equal(table.concat(charactersRead), expected)
	self:is_equal(istream:line(), line)
	self:is_equal(istream:column(), column)
	self:is_equal(istream:position(), position)
	self:is_equal(istream:peek(), nil)
	self:is_equal(istream:get(), nil)
	self:is_equal(istream:next(), nil)
	self:did_invoke_fail(istream.error, istream, "some error message")
	istream:close()
end

local function test_input_stream_pass_binary(self, istream, expected)
	local charactersRead = {}
	local position = 0
	self:is_equal(istream:line(), 0)
	self:is_equal(istream:column(), 0)
	self:is_equal(istream:position(), position)

	for _ in expected:gmatch(".") do
		table.insert(charactersRead, istream:get())
		position = position + 1
	end

	self:is_equal(table.concat(charactersRead), expected)
	self:is_equal(istream:line(), 0)
	self:is_equal(istream:column(), 0)
	self:is_equal(istream:position(), position)
	self:is_equal(istream:peek(), nil)
	self:is_equal(istream:get(), nil)
	self:is_equal(istream:next(), nil)
	self:did_invoke_fail(istream.error, istream, "some error message")
	istream:close()
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
	test_input_stream_pass(
		self,
		input_stream.fromFile("resources/input-stream/pass.txt"),
		read_file("resources/input-stream/pass.txt")
	)

	test_input_stream_pass_binary(
		self,
		input_stream.fromFile("resources/input-stream/pass-binary.txt", true),
		read_file("resources/input-stream/pass-binary.txt", true)
	)

	local buffer1 =
		"\n\t !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n"
	local buffer2 = "\n\t123456\n\t\n"
	test_input_stream_pass(self, input_stream.fromBuffer(buffer1), buffer1)
	test_input_stream_pass_binary(self, input_stream.fromBuffer(buffer2, true), buffer2)

	local istream = input_stream.fromFile("resources/input-stream/fail.txt")
	self:did_invoke_fail(istream.peek, istream)
	istream:close()

	self:did_invoke_fail(input_stream.fromFile, "bad_file")
	self:did_invoke_fail(input_stream.fromBuffer, 123)
end
