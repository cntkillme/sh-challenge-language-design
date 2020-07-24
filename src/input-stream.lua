--- Encapsulates file input and keeps track of various details.
--- @class input_stream
local input_stream = {}
input_stream.__index = input_stream

-- Constants
local BUFFER_SIZE = 1024 -- in bytes

--- Creates an input_stream given a path and file, and the stream becomes the new owner of the file.
--- @param path string
--- @param file table
--- @param binary boolean | nil
--- @return input_stream
function input_stream.new(path, file, binary)
	return setmetatable({
		_path = path,
		_file = file,
		_binary = binary,
		_buffer = "",
		_line = binary and 0 or 1,
		_column = binary and 0 or 1,
		_position = 0,
		_last_position = -1
	}, input_stream)
end

--- Creates an input_stream given a path to a file.
--- @param path string
--- @param binary boolean | nil
--- @return input_stream
function input_stream.from_file(path, binary)
	local mode = binary and "rb" or "r"
	local file = assert(io.open(path, mode))
	return input_stream.new(path, file, binary)
end

--- Creates an input_stream given a buffer.
--- @param buffer string
--- @param binary boolean | nil
--- @return input_stream
function input_stream.from_buffer(buffer, binary)
	local file = assert(io.tmpfile())
	local idx = 1

	-- Lua does not expose fwrite's limitations, so writing in chunks is safer for long buffers.
	file:setvbuf("full", BUFFER_SIZE)

	while idx <= #buffer do
		assert(file:write(buffer:sub(idx, idx + 127)), "partial write!")
		idx = idx + 128 -- assume 128 characters written successfully
	end

	file:flush()
	file:seek("set", 0)
	return input_stream.new("<buffer>", file, binary)
end

--- Closes the input_stream.
function input_stream:close()
	if self._file then
		self._file:close()
		self._file = nil
	end
end

--- Raises an error, uses the stream's line/position and column information when unspecified.
--- @param message string
--- @param line integer | nil
--- @param column integer | nil
function input_stream:error(message, line, column)
	if self._binary then
		error(("%s:%.4X: %s"):format(self._path, self._position or line, message or "error"))
	else
		error(("%s:%d:%d: %s"):format(self._path, line or self._line, column or self._column, message or "error"))
	end
end

--- Returns the current character in the stream, or `nil` if no character is available.
--- @return string | nil
function input_stream:peek()
	if not self:_check_buffer() then -- eof
		return nil
	end

	local char = self._buffer:sub(self:_buffer_index(), self:_buffer_index())

	if not self._binary then
		-- Ensure the character is in the SHLang character set.
		if not (char == "\t" or char == "\n" or (char:byte() >= 32 and char:byte() <= 126)) then
			self:error(("unexpected symbol \\x%.2X"):format(char:byte()))
		end
	end

	return char
end

--- Returns the current character in the stream then moves ahead, or `nil` if no character is available.
--- @return string | nil
function input_stream:get()
	local char = self:peek()

	if char then
		if not self._binary then
			if char == "\n" then
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

--- Returns the next character in the stream, or `nil` if no character is available.
--- @return string | nil
function input_stream:next()
	self:get()
	return self:peek()
end

--- Returns the path.
--- @return string
function input_stream:path()
	return self._path
end

--- Returns whether the stream was opened in binary mode.
--- @return boolean
function input_stream:binary()
	return self._binary
end

--- Returns the current line.
--- @return integer
function input_stream:line()
	return self._line
end

--- Returns the current column.
--- @return integer
function input_stream:column()
	return self._column
end

--- Returns the current file position.
--- @return integer
function input_stream:position()
	return self._position
end

--- @return integer
function input_stream:_buffer_index()
	return 1 + (self._position % BUFFER_SIZE)
end

--- @return boolean
function input_stream:_check_buffer()
	assert(self._file, "input_stream is not opened")

	if self._position % BUFFER_SIZE == 0 and self._position ~= self._last_position then -- update buffer
		self._buffer = self._file:read(BUFFER_SIZE)
		self._last_position = self._position
	end

	if not self._buffer or #self._buffer == 0 or self:_buffer_index() > #self._buffer then -- eof reached
		self._buffer = nil
		return false
	end

	return true
end

return input_stream
