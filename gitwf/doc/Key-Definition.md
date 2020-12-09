# Key definition

Indicates a property to be defined by name and value type.

**Format:**  
`key <identifier> <<type>> <decorators..>`

**Example:**  
`key email <string(32)> format(email) default('anonymous@example.tld') null`

## Decorators

____
`default({argument: default value})`

Sets the default value for the key.

____
`format({enum format type} {decorators..})`

Formats the value in a specific way, often appending validation and default value decorators as well.

Valid built-in format types are: `md`.
____
`null`  
`null()`

This property can be assigned a NULL value.
____
`identifier`  
`identifier()`

Indicates that this property is used as the primary key and unique identifier for this table. No two entries
within this table will have the same identifier value.
____
`unique`  
`unique()`

Indicates that this property's value must be unique for the model in question.