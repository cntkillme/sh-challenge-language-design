local input_stream = require("input-stream")

local function test_input_stream_pass(test)
	local stream = test:invoke_pass(input_stream.new, "./resources/test/input-stream/pass.txt")
	local expected = "\n\t !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n"
	local line = 1
	local column = 1
	local position = 0
	test:equal(test:invoke_pass(stream.line, stream), 1)
	test:equal(test:invoke_pass(stream.column, stream), 1)
	test:equal(test:invoke_pass(stream.position, stream), 0)

	for char in expected:gmatch('.') do
		local peekChar = test:invoke_pass(stream.peek, stream)
		local getChar = test:invoke_pass(stream.get, stream)
		test:equal(peekChar, getChar)
		test:equal(peekChar, char)

		if char == '\n' then
			line = line + 1
			column = 1
		else
			column = column + 1
		end

		position = position + 1
		test:equal(test:invoke_pass(stream.line, stream), line)
		test:equal(test:invoke_pass(stream.column, stream), column)
		test:equal(test:invoke_pass(stream.position, stream), position)
	end

	test:equal(test:invoke_pass(stream.peek, stream), nil)
	test:equal(test:invoke_pass(stream.get, stream), nil)
	test:equal(test:invoke_pass(stream.next, stream), nil)
	test:equal(test:invoke_pass(stream.line, stream), 3)
	test:equal(test:invoke_pass(stream.column, stream), 1)
	test:equal(test:invoke_pass(stream.position, stream), #expected)
	test:invoke_fail(stream.error, stream)
	test:invoke_fail(stream.error, stream, {})
	test:invoke_fail(stream.error, stream, "asd")
	test:invoke_fail(stream.error, stream, nil, 0)
	test:invoke_fail(stream.error, stream, nil, 1.1)
	test:invoke_fail(stream.error, stream, nil, (-1)^0.5)
	test:invoke_fail(stream.error, stream, nil, nil, 0)
	test:invoke_fail(stream.error, stream, nil, nil, 1.1)
	test:invoke_fail(stream.error, stream, nil, nil, (-1)^0.5)
	test:invoke_fail(stream.error, stream)
	test:invoke_pass(stream.close, stream)
	test:invoke_fail(stream.close, stream)
end

local function test_input_stream_fail(test)
	local stream = test:invoke_pass(input_stream.new, "./resources/test/input-stream/fail.txt")
	test:invoke_fail(stream.peek, stream)
	test:invoke_pass(stream.close, stream)
end

local function test_input_stream_binary_pass(test)
	local stream = test:invoke_pass(input_stream.new, "./resources/test/input-stream/pass-binary.txt", true)
	local expected = "\n\t123456\n\t\n"
	test:equal(test:invoke_pass(stream.line, stream), 0)
	test:equal(test:invoke_pass(stream.column, stream), 0)
	test:equal(test:invoke_pass(stream.position, stream), 0)

	for char in expected:gmatch('.') do
		local peekChar = test:invoke_pass(stream.peek, stream)
		local getChar = test:invoke_pass(stream.get, stream)
		test:equal(peekChar, getChar)
		test:equal(peekChar, char)
	end

	test:equal(test:invoke_pass(stream.peek, stream), nil)
	test:equal(test:invoke_pass(stream.get, stream), nil)
	test:equal(test:invoke_pass(stream.next, stream), nil)
	test:equal(test:invoke_pass(stream.line, stream), 0)
	test:equal(test:invoke_pass(stream.column, stream), 0)
	test:equal(test:invoke_pass(stream.position, stream), #expected)
	test:invoke_pass(stream.close, stream)
end

local function test_input_stream_binary_fail(test)
	test:pass("input_stream on a binary file cannot fail")
end

return function(test)
	test:invoke_fail(input_stream.new)
	test:invoke_fail(input_stream.new, {})
	test:invoke_fail(input_stream.new, "_/")
	test:invoke_fail(input_stream.new, "_/", {})
	test_input_stream_pass(test)
	test_input_stream_fail(test)
	test_input_stream_binary_pass(test)
	test_input_stream_binary_fail(test)
end
