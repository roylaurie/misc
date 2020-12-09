# Introducing LegionDB

## Basic Concepts

The following core concepts are used throughout the LegionDB project.

### Namespaces

**Namespaces** are ubiquitous in LegionDB and operate similar to filepaths within a nested hierarchy. Namespace
tokens are delimited by the / path separator character. 

By convention, creating additional namespace tokens is preferred over character separators. E.g., 'my/box/cutter'
instead of 'my/box-cutter'.

Note that the conventional root path prefix / character is always omitted.

### Models

The term **model** can refer to either:
1) An abstract concept of a data object to be represented; *Car*, *Box*, *Window*, etc. or
2) The software source-code class that implements that concept, allowing manipulation of concrete data in a logically
organized and object-oriented manner.

Model names and filenames should have the first character capitalized.

### Namepaths

**Namepaths** are used to represent the canonical name of a Model, beginning with its namespace and ending with its
class name. E.g., *my/box/Cutter* and *my/box/cutter/Sharpener* . A namepath is universally unique.

### Schemas

A **schema** is basically a table definition that describes how a **model's** data object is represented, stored,
searched, retrieved, updated, created, and deleted.

LegionDB **compiles** schemas into an internal model of its own and uses
this to manage data and interact with database servers **agnostic** of their idiosyncrasies. Schemas use common concepts found in
many **relational** database systems. This includes keys (rows), indices, links (relations), and id sharding.

Schema **files** and associated resources are located in the */schema* directory. Schemas are nested within a file structure
representing its corresponding namespace.

Schema files use the *.lgn.schema* file **extension** while the filename is always the **class name**;
*/schema/my/car/Window.lgn.schema*

### Data

Data is stored in a manner described by schemas on one or more databases and/or database types. Each database object
(property, row, etc.) is referred to as a data **Entry**. Each data object property is known by a **Key** name and
represented by data **Type**.

### Data Types

**`integer`**

**`float`**

**`string(length)`**

**`boolean`**

**`enum([options])`**

**`array<Type>`**

**`link(linkName fromProperty toProperty {decorators..})`**

**`timestamp`**

**`id`**

**`uuid`**

**`schema`**
