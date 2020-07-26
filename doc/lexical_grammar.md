# SHLang: Lexical Grammar

The lexical grammar production rules of SHLang are described here in an *EBNF-like* syntax.

```ebnf
(* At least zero lexical units. *)
input = { whitespace | comment | token };

(* At least one space, horizontal tab, or line feed. *)
whitespace = "/[ \t\n]+/";

(* A pound, followed by any number of characters (non-greedy), followed by a line feed. *)
comment = "/#(.*)?\n/";

token = keyword | identifier | number | operator | punctuator;

keyword = keyword_let | keyword_return;
let_keyword = "let";
return_keyword = "return";

(* A letter followed by at least zero alphanumeric characters and is not a keyword. *)
identifier = "/[A-Za-z][0-9A-Za-z]*/" - keyword;

(* At least one digit, optionally followed by a period and at least 1 digit. *)
number = "/\d+(\.\d+)?/";

operator = unary_operator | binary_operator | assignment_operator;
punctuator = delimiter | left_parenthesis | right_parenthesis;
delimiter = ',';
left_parenthesis = '(';
right_parenthesis = ')';
unary_operator = '$' | '-';
binary_operator = '+' | '-' | '*' | '/' | '%' | '^';
assignment_operator = '=';
```

Notes:
- terminals of the form `"/.../"` denote a regular expression;
- comments and whitespace have no semantic utility (that is, they do not change the behavior of the program);
- whitespace is used to separate tokens and are mostly optional,
	- except to separate adjacent identifiers, keywords, and/or numbers from each other.
