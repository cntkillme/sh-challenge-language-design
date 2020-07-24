local input_stream = require("input-stream")
local virtual_machine = require("virtual-machine")

--- @param self test_suite
return function(self)
	local vm = virtual_machine.new(input_stream.from_file("resources/compiler/test.bin", true))
	local result = vm:execute({ 2, 4, 6 })
	local expected = 0.128187
	local epsilon = 0.000001

	if math.abs(result - expected) > epsilon then
		self:is_equal(result, expected) -- will fail
	else
		self:pass()
	end
end
