# Chapter 2. Values and Variables
This chapter defines the semantics behind values and variables.

## 2.1. Values
All values are double-precision floating-point numbers. All values are expressions, and the evaluation of the value as an expression evaluates to itself.

Example:
```sh
let x = 8   # 8 is a value and thus an expression
		    # evaluating the expression `8` yields `8`

let y = (8) # (8) is not a value but is an expression
		    # evaluating the expression `(8)` yields `8`
```

## 2.1.1. Operations
The following operations¹ are supported in order of precedence (ascending):
1. Assignment operation (unspecified associativity) using the assignment operator (i.e. equal sign, `'='`).
	1. The associativity of the assignment operator is unspecified because assignment cannot be chained.
2. Additive operations (left-associative):
	1. Addition using the addition operator (i.e. plus, `'+`).
	2. Subtraction using the subtraction operator (i.e. minus, `'-`).
	3. The precedence of all additive operations are equivalent.
3. Multiplicative operations (left-associative):
	1. Multiplication using the multiplication operator (i.e. times, `'*'`).
	2. Division using the division operator (i.e. divide, `'/'`).
	3 The precedence of all multiplicative operations are equivalent.
4. Unary operations (unspecified associativity):
	1. Negation using the negation operator (i.e. minus, `'-'`).
	2. Argument access using the input argument access operator (i.e. dollar, `'$'`).
	3. The precedence of all unary operations are equivalent.
	4. The associativity of the unary operators is unspecified because it is redundant.
5. Exponentiation (right-associative) using the exponentiation operator (i.e. power, `'^'`).
	1. The right operand of an exponentiation expression is a unary expression, exponentiation expression, or a primary expression.

The exact rules (e.g. rounding mode) of all numeric operations¹ are dependent on the host².

Examples:
```sh
let x = 0 * 4 + -3 # x is initialized to 1
let y = 0 * 4 ^ -3 # y is initialized to 0.015625 (1/64)
let z = -$5^$$2    # z is initialized to the negation of the argument 5 to the power of argument value of argument 2
                   # i.e. -($5 ^ $($2))
```

¹ Numeric operations are all operations excluding assignment and argument access.
² Various hosts (e.g. Lua) may not specify such parameters, and so may be dependent on the host's implementation.

## 2.2. Variables
A variable is a storage location for a value.

## 2.2.1. Initialization
A variable is either explicitly initialized¹ or implicitly initialized² during its definition.

¹ Explicit initialization assigns the value of a variable to the result of the user-specified expression.\
² Implicit initialization assigns the value of a variable to `0.0`.

Examples:
```sh
let x         # implicit initialization (initialized to 0.0)
let y = 0     # explicit initialization
let z = x + y # explicit initialization
```

## 2.2.2 Lifetime
The lifetime of a variable begins immediately after definition and ends at program termination.

1. The value of a variable can only be accessed or mutated during the variable's lifetime.
2. No variable with an identical name can be defined during the variable's lifetime.
3. No function with an identical name can be defined during the variable's lifetime.

## 2.3. Parameters
A parameter (i.e. formal argument) is a storage location for a function argument (i.e. informal argument).

## 2.3.1. Initialization
A parameter is initialized to its corresponding argument whose expression is evaluated prior to a function call.

Examples:
```sh
let f(x) = x + 3 # x is a parameter
f(2 + 4)         # 6 is the argument
```

## 2.3.2. Lifetime
The lifetime of a variable begins immediately after the function is called and ends when the function returns.

1. The value of a parameter can only be accessed or mutated during the parameter's lifetime.
2. No variable with an identical name can be defined during the parameter's lifetime.
3. No parameter with an identical name can be defined during the parameter's lifetime.
