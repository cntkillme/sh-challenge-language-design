local input_stream = require("input-stream")
local virtual_machine = require("virtual-machine")

--- @param self test_suite
return function(self)
	local vm = virtual_machine.new(input_stream.from_buffer("SHLang-1\x07\0\0\0\0\0\0\0\0\x0E", true))
	self:is_equal(vm:read_byte(), 0x53) -- 'S'
	self:is_equal(vm:read_word(), 0x6E614C48) -- *(int*)"HLan"
	self:is_equal(vm:read_byte(), 0x67) -- 'g'
	vm:read_byte() -- '-'
	vm:read_byte() -- '1'
	vm:read_byte() -- '\x07'
	self:is_equal(vm:read_double(), 0)
	vm:read_byte() -- '\x0E'
	self:did_invoke_fail(vm.read_byte, vm)

	vm = virtual_machine.new(input_stream.from_file("resources/compiler/test.bin", true))
	self:is_truthy(math.abs(vm:execute(2, 4, 6) - 0.128187) < 0.000001)
end
