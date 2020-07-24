# Lexical Structure

1. General

	A source file is an ordered sequence of characters from the SHLang character set. The SHLang character set is equivalent to the *US-ASCII* character set with all control characters beside horizontal tab and line feed omitted. Any character appearing in a source file outside of the SHLang character set is ill-formed. In particular, the SHLang character set is comprised of characters with the numeric values of:
	- 0x09 (TAB), 0x0A (LF), 0x20 (SPACE) (i.e. whitespace),
	- and 0x21 through 0x7E inclusive (i.e. graphical characters).

	Graphical characters:
	```
	0 1 2 3 4 5 6 7 8 9
	A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
	a b c d e f g h i j k l m n o p q r s t u v w x y z
	! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
	```

	Conceptually, a program is executed using three steps:
	1. Lexical analysis, which translates a source file to a token stream.
	2. Syntactic analysis, which translates the token stream into SHLang bytecode.
	3. Interpretation, which decodes and executes the SHLang bytecode.

2. Lexical analysis
	1. General

		The *input* production defines the lexical structure of a SHLang source file.
		```ebnf
		input = { input-element };
		input-element = whitespace | comment | token;
		```

		Three basic elements make up the lexical structure of SHLang: whitespace, comments, and tokens. Only tokens are significant in the syntactic grammar of an SHLang program. If the final character of a SHLang source file is not a line feed, the compiler may artificially insert one before the EOF marker.

	2. Comments

		A comment begins with the pound (`#`) character and extends to the end of the line.

		```ebnf
		comment = '#' { character } '\n';
		```

		Example:
		```sh
		# a comment
		let x = 5
		let f(x) = x + 3
		# another comment
		```

	3. Whitespace

		Whitespace is a sequence of at least one whitespace character. A whitespace character is defined as either the space, horizontal tab (`\t`), or line feed (`\n`) character.

		```ebnf
		whitespace = { whitespace-character } whitespace-character;
		whitespace-character = ' ' | '\t' | '\n';
		```

3. Tokens
	1. General

		There are several kinds of tokens: identifiers, keywords, literals, operators, and punctuators. Whitespace and comments are not tokens, though whitespace acts as a separator for tokens.

		```ebnf
		token = identifier | keyword | number-literal | operator-or-punctuator;
		```

	2. Identifiers

		An identifier is a sequence of one alphabetical character, followed by at least zero alphanumerical characters, and is not a keyword.

		```ebnf
		identifier = identifier-start { identifier-part };
		identifier-start = ? all letters in US-ASCII ?;
		identifier-part = ? all letters and digits in US-ASCII ?;
		```

	3. Keywords

		A keyword is a reserved identifier-like sequence of characters.

		```ebnf
		keyword = 'let' | 'return';
		```

	4. Literals
		1. General

			A literal is a source code representation of a value.
		2. Number literals

			Number literals are used to denote number values. The value of a number literal is implementation-defined, though the inherent type of a number shall be a double-precision floating-point number. A number is a sequence of at least one digit, optionally followed by a period (`.`) and at least one digit.

			```ebnf
			number-literal = digit { digit } ['.' digit { digit }];
			```

	5. Operators and punctuators

		Operators are used in expressions to denote an operation involving one or more operands. Punctuators are used for grouping and separating.

		```ebnf
		operator-or-punctuator = operator | punctuator;
		operator = '$' | '=' | '+' | '-' | '*' | '/' | '%' | '^';
		punctuator = ',' | '(' | ')';
		```
