--- The virtual machine class encapsulates the entire runtime of SHLang.
local virtual_machine = {}
virtual_machine.__index = virtual_machine

--- Creates a new virtual_machine.
--- @param istream input_stream
function virtual_machine.new(istream)
	return setmetatable({
		_pc = 0,
		_istream = istream
		-- implementation defined
	}, virtual_machine)
end

--- Executes SHLang bytecode and returns the result of the final expression.
--- @param inputs number[]
--- @return number
function virtual_machine:execute(inputs) -- luacheck: ignore 212/inputs
	error("virtual_machine::execute(): not yet implemented!")
end

--- Reads a byte from the stream.
--- @return integer
function virtual_machine:read_byte()
	local char = self._istream:get()

	if not char then
		self._istream:error("eof unexpected")
	end

	self._pc = self._pc + 1
	return char:byte()
end

--- Reads a word from the stream.
--- @return integer
function virtual_machine:read_word()
	local chars = {}
	self._pc = self._pc + 4

	for idx = 1, 4 do
		local char = self._istream:get()
		chars[idx] = char

		if not char then
			self._istream:error("eof unexpected")
		end
	end

	return string.unpack("<i4", table.concat(chars))
end

--- Reads a double from the stream.
--- @return integer
function virtual_machine:read_double()
	local chars = {}
	self._pc = self._pc + 8

	for idx = 1, 8 do
		local char = self._istream:get()
		chars[idx] = char

		if not char then
			self._istream:error("eof unexpected")
		end
	end

	return string.unpack("<d", table.concat(chars))
end

return virtual_machine
