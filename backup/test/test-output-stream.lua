local output_stream = require("output-stream")

local function test_output_stream_pass(test)
	local stream = test:invoke_pass(output_stream.new, "./resources/test/output-stream/pass.txt")
	local written = "\n\t !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n"
	local line = 1
	local column = 1
	local position = 0
	test:equal(test:invoke_pass(stream.line, stream), 1)
	test:equal(test:invoke_pass(stream.column, stream), 1)
	test:equal(test:invoke_pass(stream.position, stream), 0)

	for char in written:gmatch('.') do
		test:invoke_pass(stream.write, stream, char)

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

	test:invoke_pass(stream.flush, stream)
	local file = assert(io.open("./resources/test/output-stream/pass.txt", 'r'))
	test:equal(file:read("*a"), written)
	file:close()
	test:equal(test:invoke_pass(stream.line, stream), 3)
	test:equal(test:invoke_pass(stream.column, stream), 1)
	test:equal(test:invoke_pass(stream.position, stream), #written)
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

local function test_output_stream_fail(test)
	local stream = test:invoke_pass(output_stream.new, "./resources/test/output-stream/fail.txt")
	test:invoke_fail(stream.write, stream, string.char(1))
	test:invoke_pass(stream.close, stream)
end

local function test_output_stream_binary_pass(test)
	local stream = test:invoke_pass(output_stream.new, "./resources/test/output-stream/pass-binary.txt", true)
	local written = "\n\t123456\n\t\n"
	test:equal(test:invoke_pass(stream.line, stream), 0)
	test:equal(test:invoke_pass(stream.column, stream), 0)
	test:equal(test:invoke_pass(stream.position, stream), 0)
	test:invoke_pass(stream.write, stream, written)
	test:invoke_pass(stream.flush, stream)
	local file = assert(io.open("./resources/test/output-stream/pass-binary.txt", "rb"))
	test:equal(file:read("*a"), written)
	file:close()
	test:equal(test:invoke_pass(stream.line, stream), 0)
	test:equal(test:invoke_pass(stream.column, stream), 0)
	test:equal(test:invoke_pass(stream.position, stream), #written)
	test:invoke_pass(stream.close, stream)
end

local function test_output_stream_binary_fail(test)
	test:pass("output_stream on a binary file cannot fail")
end

return function(test)
	test:invoke_fail(output_stream.new)
	test:invoke_fail(output_stream.new, {})
	test:invoke_fail(output_stream.new, "_/")
	test:invoke_fail(output_stream.new, "_/", {})
	test_output_stream_pass(test)
	test_output_stream_fail(test)
	test_output_stream_binary_pass(test)
	test_output_stream_binary_fail(test)
end
