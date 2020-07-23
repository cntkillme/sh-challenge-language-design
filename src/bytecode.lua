--- Specifies all instruction formats and opcodes.
local bytecode = {}

--- Specifies the encoding of instructions and their operand (if applicable).
local formats = {
	iv = 0, -- void (no operand)
	ib = 1, -- byte
	iw = 4, -- word
	id = 8  -- double
}

--- Specifies all the instructions.
local instructions = {
	-- Arithmetical instructions
	add = { format = formats.iv, opcode = 0x00 }, -- b = pop(); a = pop(); push(a + b)
	sub = { format = formats.iv, opcode = 0x01 }, -- b = pop(); a = pop(); push(a - b)
	mul = { format = formats.iv, opcode = 0x02 }, -- b = pop(); a = pop(); push(a * b)
	div = { format = formats.iv, opcode = 0x03 }, -- b = pop(); a = pop(); push(a / b)
	rem = { format = formats.iv, opcode = 0x04 }, -- b = pop(); a = pop(); push(a % b)
	exp = { format = formats.iv, opcode = 0x05 }, -- b = pop(); a = pop(); push(a ^ b)
	neg = { format = formats.iv, opcode = 0x06 }, -- push(-pop())

	-- Stack instructions
	imm = { format = formats.id, opcode = 0x07 }, -- push(operand)
	cpy = { format = formats.ib, opcode = 0x08 }, -- push(STACK(operand))
	rep = { format = formats.ib, opcode = 0x09 }, -- STACK(operand) = pop()
	gbl = { format = formats.ib, opcode = 0x0A }, -- push(GLOBAL(operand))
	inp = { format = formats.iv, opcode = 0x0B }, -- push(INPUT(pop()))

	-- Control flow instructions
	arg = { format = formats.ib, opcode = 0x0C }, -- ARGCOUNT(operand)
	inv = { format = formats.iw, opcode = 0x0D }, -- INVOKE(operand)
	ret = { format = formats.iv, opcode = 0x0E }  -- RETURN()
}

bytecode.formats = formats
bytecode.instructions = instructions

return bytecode
