--- Input Stream Class
-- @author CntKillMe

local input_stream = {}
input_stream.__index = input_stream
input_stream.BUFFER_SIZE = 512

function input_stream.new(path, binary)
	assert(type(path) == "string", "path must be a string")
	assert(type(binary) == "nil" or type(binary) == "boolean", "binary must be a boolean")
	local mode = binary and "rb" or 'r'
	local file = assert(io.open(path, mode))

	return setmetatable({
		_path = path,
		_file = file,
		_binary = not not binary,
		_buffer = "",
		_line = binary and 0 or 1,
		_column = binary and 0 or 1,
		_position = 0,
		_last_position = -1
	}, input_stream)
end

function input_stream:close()
	assert(self._file, "input_stream already closed")
	self._file:close()
	self._file = nil
end

function input_stream:error(message, line, column)
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

function input_stream:peek()
	if not self:_check_buffer() then -- eof
		return nil
	end

	local char = self._buffer:sub(self:_pointer(), self:_pointer())

	if not self._binary then
		-- not horizontal tab, form feed, or printable (CR not handled).
		if not (char == '\n' or char == '\t' or (char:byte() >= 32 and char:byte() <= 126)) then
			self:error(("unexpected symbol \\x%X"):format(char:byte()))
		end
	end

	return char
end

function input_stream:get()
	local char = self:peek()

	if char then
		if not self._binary then
			if char == '\n' then
				self._line = self._line + 1
				self._column = 1
			else
				self._column = self._column + 1
			end
		end

		self._position = self._position + 1
	end

	return char
end

function input_stream:next()
	self:get()
	return self:peek()
end

function input_stream:line()
	return self._line
end

function input_stream:column()
	return self._column
end

function input_stream:position()
	return self._position
end

function input_stream:_pointer()
	return 1 + (self._position % self.BUFFER_SIZE)
end

function input_stream:_check_buffer()
	assert(self._file, "input_stream is not opened")

	-- buffer needs to be updated
	if self._position % self.BUFFER_SIZE == 0 and self._position ~= self._last_position then
		self._buffer = self._file:read(self.BUFFER_SIZE)
		self._last_position = self._position
	end

	-- eof reached
	if not self._buffer or #self._buffer == 0 or self:_pointer() > #self._buffer then
		self._buffer = nil
		return false
	end

	return true
end

return input_stream
