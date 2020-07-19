# Variables

1. General
	Variables represent storage locations for numbers. Variables are either implicitly initialized or explicitly initialized.

	Implicit initialization initializes a variable to the value `0` and occurs when a variable is not explicitly initialized.

	Explicit initialization initializes a variable to the value of the initializing expression.
	Example:
	```sh
	let x         # implicit initialization (initialized to 0)
	let y = 3 + 5 # explicit initialization (initialized to 8)
	```

2. Variable categories
	1. General

		SHLang defines two categories of variables: global variables and parameters.

	2. Global variables

		A global variable is a variable declared by a variable definition. A global variables comes into existence after its definition. A global variable ceases to exist when the program terminates. A global variable may be reassigned at any time during its existence.

		Example:
		```sh
		# let z = x   # ill-formed, global variable `x` not defined
		let x = 3     # x is a global variable
		let y = x + 2 # y is a global variable
		```

	3. Parameters

		A parameter is a variable that comes into existence upon invocation of the function to which the parameter belongs, and is initialized with the value of the argument given in the invocation. A parameter ceases to exist when execution of the function completes. Parameter access takes precedence over global variable access.

		Example:
		```sh
		let x = 5    # x is a global variable
		let f(x) = x # x refers to a parameter
		let g(y) = x # x refers to the global variable
		```
