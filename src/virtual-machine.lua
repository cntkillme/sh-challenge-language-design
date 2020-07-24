--- The virtual machine class encapsulates the entire runtime of SHLang.
local virtual_machine = {}
virtual_machine.__index = virtual_machine

--- Creates a new virtual_machine.
--- @param istream input_stream
function virtual_machine.new(istream) -- luacheck: ignore 212/istream
	return setmetatable({
		-- implementation defined
	}, virtual_machine)
end

--- Executes SHLang bytecode and returns the result of the final expression.
--- @param inputs number[]
--- @return number
function virtual_machine:execute(inputs) -- luacheck: ignore 212/inputs
	error("virtual_machine::execute(): not yet implemented!")
end

return virtual_machine
