# SHLang: Execution Model
The execution model of SHLang is described here.

## Introduction
An SHLang source file is compiled into an SHLang object file, which is then executed by the SHLang virtual machine.
This document specifies the behavior of SHLang virtual machine and the SHLang object file format.

## Object File Format
An SHLang object file comprises of the signature (which is a sequence of ASCII characters), and a contiguous sequence of instructions.

Offset | Content
-------|-------------------------
0      | Signature (`"SHLang-1"`)
8      | Instruction[]

## Instruction Format
An instruction format specifies the encoding of a particular set of instructions. SHLang instructions are not fixed-size; in general, an instruction is comprised of a one byte opcode which may be followed by an operand.

Format | Layout     | Description
-------|------------|----------------------------------------
iv     | opcode     | no operands
ib     | opcode u8  | one-byte unsigned integral operand
iw     | opcode i32 | four-byte signed integral operand
id     | opcode f64 | double-precision floating point operand

Note: operands are encoded in little-endian.

## Registers
Although the SHLang virtual machine is a stack based virtual machine, various registers are used to hold various state that cannot exist on the stack.

Register | Description
---------|-------------------------------------------------------------
pc       | program counter; address of the next instruction
sp       | stack pointer; address of the top of the stack
bp       | base pointer; address of the base of the current stack frame

## Memory Layout
Instruction memory is fully isolated from the stack.

### Stack
The stack is an eight-byte addressable array of double-precision floating point numbers which comprise of all variables, parameters, and temporary values. Every stack slot holds a double-precision floating point number.

The stack pointer register (sp) holds the address of the top of this stack (i.e. the address of the last value pushed) and is changed every time a value is pushed to or popped from the stack. The initial value of the stack pointer is initialized to a fixed value (generally `0`) and crossing this boundary results shall result in a stack underflow. The stack is not required to be bounded.

The base pointer register (bp) holds the address of the base of the current stack frame and is changed every time a function is called or returns. A stack frame is a portion of the stack used to hold all the data a function requires (i.e. parameters, temporaries, and the return value) and may hold a maximum of 255 values. As such, the size of a stack frame is bounded by the closed interval `[1, 255]`.

### Instruction Memory
Instruction memory is a one-byte addressable array of bytes comprising of the entire object file beyond the signature (see [object file format](#Object%20File%20Format)).

The first eight bytes constitute the signature, and all remaining bytes make up the instructions of the program. The program counter register (pc) holds the address of the next instruction to execute.

All instructions are executed sequentially, and deviation from this order only occurs for function calls (`inv`) and returns (`ret`).

## Instruction Reference
Opcode | Format | Mnemonic | Description
-------|--------|----------|-----------------------------------------------------------------------------
0x00   | iv     | add      | t=pop() push(pop() + t)
0x01   | iv     | sub      | t=pop() push(pop() - t)
0x02   | iv     | mul      | t=pop() push(pop() * t)
0x03   | iv     | div      | t=pop() push(pop() / t)
0x04   | iv     | rem      | t=pop() push(pop() % t)
0x05   | iv     | pow      | t=pop() push(pop() ^ t)
0x06   | iv     | neg      | push(-pop())
0x07   | id     | imm f64  | push(f64)
0x08   | ib     | cpy u8   | push(stack[bp + u8])
0x09   | ib     | rep u8   | stack[bp + u8] = pop()
0x0A   | ib     | gbl u8   | push(stack[u8])
0x0B   | ib     | inp u8   | push(inputs[u8] || NaN)
0x0C   | ib     | arg u8   | SAVE_ARGC(u8)
0x0D   | iw     | inv i32  | SAVE_PC() SAVE_BP() pc += i32 bp = min(sp, sp - GET_ARGC() + 1)
0x0E   | iv     | ret      | value = pop() sp = sp - RESTORE_ARGC() push(value) RESTORE_BP() RESTORE_PC()
0x0F   | iv     | hlt      | halt()

The instruction reference uses various macros to denote implementation-defined behavior. Specifically, the method used to save argc, pc, and bp are unspecified by the standard but must be implemented to support nested function calls.

Additionally, executing invalid bytecode is undefined behavior; the virtual machine may assume the bytecode is valid and is in line with the semantics of the language. The only exception is when validating the signature of a SHLang object file; the behavior of an incompatible or invalid signature is implementation-defined.

Note:
- the behavior of executing invalid bytecode is undefined:
	- the bytecode may be assumed to be valid and follows the semantics of language,
	- except in the case of a differing signature, in which case the behavior is implementation-defined;
- attempting to access a non-existent input argument yields NaN (not a number);
- the method used to save and restore argc, pc, and bp is implementation-defined but most support nesting function calls.

## Input Arguments
The SHLang virtual machine accepts up to 255 inputs that the program may use through the `inp` instruction. Attempting to access an input argument
