# SHLang: Syntactic Grammar

The syntactic grammar production rules of SHLang are described here in an *EBNF-like* syntax.
```ebnf
program = { statement } return_keyword expression;

statement = function_definition | variable_assignment | variable_definition;
function_definition = let_keyword identifier left_parenthesis [{ identifier delimiter } identifier] right_parenthesis assignment_operator expression;
variable_assignment = identifier assignment_operator expression;
variable_definition = let_keyword identifier [assignment_operator expression];

expression = unary_expression | binary_expression | primary_expression;
unary_expression = unary_operator expression;
binary_expression = expression binary_operator expression;
primary_expression = number | identifier | call_expression | left_parenthesis expression right_parenthesis;
call_expression = identifier left_parenthesis [{ expression delimiter } expression] right_parenthesis;
```

Notes:
- various non-terminals from the [lexical grammar](lexical_grammar.md) are used here;
- operator precedence and associativity is not specified in this grammar (see below);
- optional whitespace usage is omitted for clarity.

## Operator Precedence
Operator | Description    | Precedence | Associativity
---------|----------------|------------|--------------
`()`     | function call  | 1          |
`^`      | power          | 2          | right-to-left
`$`      | input          | 3          |
`-`      | negation       | 3          |
`* / %`  | multiplicative | 4          | left-to-right
`+ -`    | additive       | 5          | left-to-right

Note: specifying associativity for unary operators (input and negation) as well as the function call pseudo operator is redundant so it has been omitted.

## Alternative Rules
Alternative grammar production rules for expressions that take into account operator precedence and associativity is described here.

```ebnf
expression = additive_expression;
additive_expression = additive_expression ('+' | '-') multiplicative_expression | multiplicative_expression;
multiplicative_expression = multiplicative_expression ('*' | '/' | '%') unary_expression | unary_expression;
unary_expression = ('$' | '-') unary_expression | power_expression;
power_expression = primary_expression '^' unary_expression | primary_expression;
primary_expression = number | identifier | call_expression | left_parenthesis expression right_parenthesis;
```
