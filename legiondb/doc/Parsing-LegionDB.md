# Parsing Schemas

Schema definition files are comprised of single line **statements**. Each statement describes a **definition**. Statements are nested
within each other using indentation corresponding to hierarchy. Parent statements end with a trailing `:` character. Child statements
begin with a further level of indentation.

Indentation consists of sequences of all space or tab characters. The first indented line sets
the standard for the rest of the file. The same indentation character and number of characters per level of indentation
is used throughout the file. 

Statements are comprised of lexical **tokens** separated by a single whitespace character.

**Identifier tokens** follow the regex pattern `/[a-zA-Z_]+/`.

**Value tokens** represent raw string, integer, float, hexadecimal, boolean values and arrays. Syntax and constraints for these values
follow those used in Javascript. E.g., `'my string'` `32` `0.008` `0xaf13` `true` `['dog',2,thefunc()]` 

**Type tokens** represent the data type of a value, rather than the value itself. They are encapsulated by the `<` and `>`
characters, known as the _type open_ and _type close_ tokens. Within is either a _type name token_ representing a built-in type
or a _reference token_ representing the type of previously declared schema key.

E.g., `<string>` `<boolean>` `<float>` or `<Task.id>` `<Animal.description>`

Some built-in types accept further data-type constraints by acting as _function tokens_. For example: `<string(32)>` declares a string
with a maximum character limit of 32 characters, `enum([cat,dog])` declares an enumeration that may be either `cat` or `dog`.

**Reference tokens** refer to a specific key within a schema, resolving to either the value of the key or its data type,
depending on context. It consists of a word token representing a valid schema classname within the global namespace followed
by a word token representing a valid key name within the specified schema. The two values are separated by a `.` character. E.g., `Task.id` `MyClass.description`, etc.

**Function tokens** represent operations that accept a list of inputs and return an output. They begin with a word token referred to as the _function name token_ and encapsulate a whitespace delimited
list of parameters using the `(` and `)` characters, known as the _function open_ and _function close_ tokens respectively.

Each function name is unique within a global namespace. Functions accept
a whitespace separated list of tokens that serve as **arguments**, followed by a whitespace delimited list of tokens
that behave as **decorators**. These two groups comprise a _function parameter list token_. A function call without any parameters performs a default operation. If the encapsulating
parenthesis are omitted, the function also performs a default operation.

The first token of a statement is a word token that indicates the definition type (`schema`, `key`, etc.), known as a _definition type token_.

Following the _definition type token_, definition statements accept a whitespace separated list of tokens that serve as **arguments**,
followed by a whitespace delimited list of tokens that behave as **decorators**.l

## Definitions

* [schema](Schema-Definition.md)
* [key](Key-Definition.md)
* [index](Index-Definition.md)


