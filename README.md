# Scripting Helpers: Language Design Challenge
[![test](https://github.com/cntkillme/sh-challenge-language-design/workflows/test/badge.svg)](https://github.com/cntkillme/sh-challenge-language-design/actions)
[![codecov](https://codecov.io/gh/cntkillme/sh-challenge-language-design/branch/master/graph/badge.svg)](https://codecov.io/gh/cntkillme/sh-challenge-language-design)

An overview of the SHLang specification can be seen [here](doc/contents.md).

## Requirements
The user is to complete the implementation of a compiler and an interpreter for SHLang. Various utilities and classes are already provided and the user is expected to make use of them.

The use of lexer/parser generation tools or the usage of another user's submission is prohibited.

Process:
1. Tokenizer (input: SHLang source file, output: token stream)
	- May be combined with syntax analysis.
2. Syntax Analysis (input: token stream, output: undecorated AST)
	- AST node classes are provided (see: [ast directory](src/compiler/ast)).
	- Placeholder class is provided (see: [parser](src/compiler/parser.lua) class).
3. Semantic Analysis (input: undecorated abstract syntax tree, output: decorated AST)
	- Completely provided (see: [ast_constrainer](src/compiler/visitors/ast-constrainer.lua) class).
4. Code Generation (input: decorated AST, output: SHLang bytecode)
	- Completely provided (see: [ast_codegen](src/compiler/visitors/ast-codegen.lua) class).
5. Execution (input: SHLang bytecode, output: number)
	- Various utility functions are provided (see: [virtual_machine](src/virtual-machine.lua) class).

The [compiler](src/compiler/compiler.lua) class provides an interface to the entire compilation process. To begin testing, uncomment the relevant tests in [src/main.lua](src/main.lua).

## Testing
In the project's root directory, invoke Lua 5.3 to run the file `src/main.lua`.

## Contributing
The user may file an issue for the following reasons:
- to report meta issues (e.g. code/documentation clarity, conciseness, consistency, formatting, etc.),
- to report technical issues (e.g. runtime errors, logic errors, etc.),
- and to suggest changes to the SHLang specification.

The user may create a pull request for the following reasons:
- to fix an issue (see above),
- and to contribute additional tests and test cases.

## Submitting
The user's submission is judged solely based on the amount of passing test cases.
