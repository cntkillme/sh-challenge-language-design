--- Specifies all instruction formats and opcodes.
local bytecode = {}

--- Specifies the encoding of instructions and their operand (if applicable).
local formats = {
	iv = 0, -- void (no operand)
	ib = 1, -- byte
	iw = 4, -- word
	id = 8  -- double
}

--- Specifies all instructions' opcode and format.
local instructions = {
	-- Arithmetical instructions
	add = { format = formats.iv, opcode = 0x00 },
	sub = { format = formats.iv, opcode = 0x01 },
	mul = { format = formats.iv, opcode = 0x02 },
	div = { format = formats.iv, opcode = 0x03 },
	rem = { format = formats.iv, opcode = 0x04 },
	exp = { format = formats.iv, opcode = 0x05 },
	neg = { format = formats.iv, opcode = 0x06 },

	-- Stack instructions
	imm = { format = formats.id, opcode = 0x07 },
	cpy = { format = formats.ib, opcode = 0x08 },
	rep = { format = formats.ib, opcode = 0x09 },
	gbl = { format = formats.ib, opcode = 0x0A },
	inp = { format = formats.iv, opcode = 0x0B },

	-- Control flow instructions
	arg = { format = formats.ib, opcode = 0x0C },
	inv = { format = formats.iw, opcode = 0x0D },
	ret = { format = formats.iv, opcode = 0x0E }
}

bytecode.formats = formats
bytecode.instructions = instructions

return bytecode
