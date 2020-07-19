--- Output Stream Class
-- @author CntKillMe

local output_stream = {}
output_stream.__index = output_stream
output_stream.BUFFER_SIZE = 512

function output_stream.new(path, binary)
	assert(type(path) == "string", "path must be a string")
	assert(type(binary) == "nil" or type(binary) == "boolean", "binary must be a boolean")
	local mode = binary and "wb" or 'w'
	local file = assert(io.open(path, mode))
	file:setvbuf("full", output_stream.BUFFER_SIZE)

	return setmetatable({
		_path = path,
		_file = file,
		_binary = not not binary,
		_line = binary and 0 or 1,
		_column = binary and 0 or 1,
		_position = 0,
	}, output_stream)
end

function output_stream:close()
	assert(self._file, "output_stream already closed")
	self._file:close()
	self._file = nil
end

function output_stream:error(message, line, column)
	assert(type(message) == "nil" or type(message) == "string",
		"message must be a string")
	assert(type(line) == "nil" or (type(line) == "number" and line % 1 == 0 and line > 0),
		"line must be a positive integer")
	assert(type(column) == "nil" or (type(column) == "number" and column % 1 == 0 and column > 0),
		"column must be a positive integer")
	line = line or self._line
	column = column or self._column

	if message then
		error(("%s:%d:%d: %s"):format(self._path, line, column, message))
	else
		error(("%s:%d:%d: error"):format(self._path, line, column))
	end
end

function output_stream:write(str)
	assert(self._file, "output_stream is not opened")

	if not self._binary then
		for char in str:gmatch('.') do
			if char == '\n' then -- CR not handled
				self._line = self._line + 1
				self._column = 1
			elseif char == '\t' or (char:byte() >= 32 and char:byte() <= 126) then -- horizontal tab or printable
				self._column = self._column + 1
			else
				self:error(("unexpected symbol \\x%X"):format(char:byte()))
			end
		end
	end

	self._position = self._position + #str
	assert(pcall(self._file.write, self._file, str))
end

function output_stream:flush()
	assert(self._file, "output_stream is not opened")
	self._file:flush()
end

function output_stream:line()
	return self._line
end

function output_stream:column()
	return self._column
end

function output_stream:position()
	return self._position
end

return output_stream
