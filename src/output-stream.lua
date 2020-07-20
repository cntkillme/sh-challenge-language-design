--- Encapsulates file output and keeps track of various details.
--- @class output_stream
local output_stream = {}
output_stream.__index = output_stream

-- constants
local BUFFER_SIZE = 512 -- in bytes

--- Creates an output_stream given a path and file, and the stream becomes the new owner of the file.
--- @param path string
--- @param file table
--- @param binary boolean | nil
--- @return output_stream
function output_stream.new(path, file, binary)
	return setmetatable({
		_path = path,
		_file = file,
		_binary = binary,
		_line = binary and 0 or 1,
		_column = binary and 0 or 1,
		_position = 0
	}, output_stream)
end

--- Creates an input_stream given a path to a file.
--- @param path string
--- @param binary boolean | nil
--- @return output_stream
function output_stream.from_file(path, binary)
	local mode = binary and "wb" or "w"
	local file = assert(io.open(path, mode))
	file:setvbuf("full", BUFFER_SIZE)
	return output_stream.new(path, file, binary)
end

--- Creates an output_stream using stdout.
--- @param binary boolean | nil
--- @return output_stream
function output_stream.from_stdout(binary)
	return output_stream.new("<stdout>", io.stdout, binary)
end

--- Closes the output_stream.
function output_stream:close()
	if self._file and self._file ~= io.stdout then
		self._file:close()
		self._file = nil
	end
end

--- Raises an error, uses the stream's line/position and column information when unspecified.
--- @param message string
--- @param line number | nil
--- @param column number | nil
function output_stream:error(message, line, column)
	if self._binary then
		error(("%s:%.4X: %s"):format(self._path, self._position or line, message or "error"))
	else
		error(("%s:%d:%d: %s"):format(self._path, line or self._line, column or self._column, message or "error"))
	end
end

--- Writes to the output_stream.
--- @param chunk string
function output_stream:write(chunk)
	assert(self._file, "output_stream is not opened")

	if not self._binary then
		for char in chunk:gmatch('.') do
			-- ensure character is in the SHLang character set
			if char == '\n' then
				self._line = self._line + 1
				self._column = 1
			elseif char == '\t' or (char:byte() >= 32 and char:byte() <= 126) then
				self._column = self._column + 1
			else
				self:error(("unexpected symbol \\x%.2X"):format(char:byte()))
			end
		end
	end

	-- Lua does not expose fwrite's limitations, so writing in chunks is safer for long buffers.
	local idx = 1

	while idx <= #chunk do
		assert(self._file:write(chunk:sub(idx, idx + 127)), "partial write!")
		idx = idx + 128 -- assume 128 characters written successfully
	end

	self._position = self._position + #chunk
end

--- Flushes the output_stream.
function output_stream:flush()
	if self._file then
		self._file:flush()
	end
end

--- Returns the current line.
--- @return number
function output_stream:line()
	return self._line
end

--- Returns the current column.
--- @return number
function output_stream:column()
	return self._column
end

--- Returns the current file position.
--- @return number
function output_stream:position()
	return self._position
end

return output_stream
