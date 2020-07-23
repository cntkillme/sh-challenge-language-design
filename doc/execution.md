# Execution

1. General

	SHLang is executed by first compiling a SHLang source file into an SHLang object file. The SHLang object file is comprised of all the SHLang bytecode instructions that a program is made up of. The structure of an SHLang object file is as follows:
	1. an 8-byte signature (`"SHLang-1"`) is at the start of a file,
	2. and a consecutive list of 0 or more SHLang bytecode instructions follow.

	The virtual machine may assume the bytecode is well-formed.

2. Registers

	The SHLang virtual machine is a stack-based machine consisting of the following registers:
	- the program counter (pc) register holds the address of the next instruction,
	- the stack pointer (sp) register holds the address of the top of the stack,
	- and the base pointer (bp) register holds the address of the base of the current stack frame.

3. Memory layout
	1. General

		The SHLang virtual machine separates instructions from data. All instructions live in instruction memory whereas all data (variables, parameters, and temporaries) live in the value stack.

	2. Value stack

		The value stack (i.e. stack) is an 8-byte addressable array of doubles which comprise of all variables, parameters, and temporaries. The stack pointer (sp) register holds the address of the top of the stack (i.e. the address of the last value pushed) and is altered every time a value is pushed to or popped from the value stack.

		Indexing into the value stack is relative to the current stack frame. Every function call creates a stack frame with the base pointer (bp) register set to either the position of the first parameter, or the top of the stack if there are no parameters.

	3. Instruction memory

		Instruction memory is a one-byte addressable array of all bytecode instructions. Additionally, the first eight bytes of instruction memory is comprised of the SHLang bytecode signature (`"SHLang-1"`). In essence, instruction memory is the contents of an entire object code file. The program counter (pc) register holds the address of the next instruction to execute.

3. Instruction set
	1. General

		All instructions are executed sequentially, and deviation from this only occurs for invokes (inv) and returns (ret).

	2. Instruction formats

		Every SHLang instruction is encoded exactly as specified by its instruction format. There are four instruction formats:
		- the void instruction format (iv) denotes no operands,
		- the byte instruction format (ib) denotes a 1 byte integral operand,
		- the word instruction format (iw) denotes a 4 byte integral operand,
		- and the double instruction format (id) denotes an 8 byte floating-point number operand.

		The opcode (one byte) precedes any operand (if applicable). All operands are encoded in little-endian.

	3. Arithmetic instructions
		1. General

			Arithmetic instructions take (by popping) their operands from the top of the stack and yield their result on the top of the stack. For instance, the expression `5 - 10` would be compiled into:
			```
			imm 5    ; stack: 5
			imm 10   ; stack: 5 10
			sub      ; stack: -5
			```

		2. The add instruction

			Opcode: 0x00, Format: iv.

			Yields the sum of two numbers.
			```
			b = pop()
			a = pop()
			push(a + b)
			```

		3. The sub instruction

			Opcode: 0x01, Format: iv.

			Yields the difference of two numbers.
			```
			b = pop()
			a = pop()
			push(a + b)
			```

		4. The mul instruction

			Opcode: 0x02, Format: iv.

			Yields the product of two numbers.
			```
			b = pop()
			a = pop()
			push(a * b)
			```

		5. The div instruction

			Opcode: 0x03, Format: iv.

			Yields the quotient of two numbers.
			```
			b = pop()
			a = pop()
			push(a / b)
			```

		6. The rem instruction

			Opcode: 0x04, Format: iv.

			Yields the remainder of division of two numbers.
			```
			b = pop()
			a = pop()
			push(a % b)
			```

		7. The exp instruction

			Opcode: 0x05, Format: iv.

			Yields the exponentiation of two numbers.
			```
			b = pop()
			a = pop()
			push(a ^ b)
			```

		8. The neg instruction

			Opcode: 0x06, Format: iv.

			Yields the additive inverse of a number.

			```
			push(-pop())
			```

	4. Stack instructions
		1. General

			Stack instructions are instructions that generally deal with the stack.

		2. The imm instruction

			Opcode: 0x07, Format: id.

			Pushes an immediate 8 byte floating-point number onto the stack.
			```
			push(operand)
			```

		3. The cpy instruction

			Opcode: 0x08, Format: ib.

			Copies the value at some position in the stack and pushes it on the top. The stack index is relative to the current stack frame.
			```
			push(STACK(operand))
			```

		4. The rep instruction

			Opcode: 0x09, Format: ib.

			Replaces the value at some position in the stack by the result on the top of the stack. The stack index is relative to the current stack frame. Format: ib.
			```
			STACK(operand) = pop()
			```

		5. The gbl instruction

			Opcode: 0x0A, Format: ib.

			Pushes the value of a global (i.e. non-parameter variable) on the top of the stack. Just like parameters, globals live on the stack, though they reside at the bottom of the stack instead of relative to the base pointer.
			```
			push(GLOBAL(operand)) ; GLOBAL(operand) indicates indexing from the bottom of the stack.
			```

		6. The inp instruction

			Opcode: 0x0B, Format: iv.

			Pushes the value of an input argument on the top of the stack, or NaN is pushed if the operand does not refer to a valid input argument.
			```
			push(INPUT(operand))
			```

	5. Control flow instructions
		1. General

			Control flow instructions alter the program's flow by moving the program counter.

		2. The arg instruction

			Opcode: 0x0C, Format: ib.

			Denotes how many arguments the following invoke will take (i.e. the argument count). This instruction must always precede an invoke (inv) instruction.
			```
			ARGCOUNT(operand)
			```

		3. The inv instruction

			Opcode: 0x0D, Format: iw.

			Invokes a function. This instruction must be preceded by an argument count (arg) instruction. The operand specifies a PC-relative address the program counter (pc) register will be set to. Additionally, the value of the program counter (pc) prior to the call (i.e. the return address) will be saved and the value of the base pointer (bp) will be saved. The details of the how the return addresses and base pointers are saved is implementation-defined.
			```
			PUSHPC()
			PUSHBP()
			pc = pc + operand
			bp = MAX(sp, sp - ARGCOUNT() + 1)
			```

			Example:
			```
			imm 0
			imm 1
			arg 2
			inv 100  ; invokes with 2 arguments (0 and 1)
			```

		4. The ret instruction

			Opcode: 0x0E, Format: iv.

			Returns from a function. The program counter (pc) register is updated to the last saved return address and the base pointer (bp) register is updated to the last saved base pointer. Additionally, the value that was originally on the top of the stack will remain on the top of the stack after all arguments are removed.
			```
			retval = TOP()
			sp = bp
			bp = POPBP()
			push(retval)
			pc = POPPC()
			```
