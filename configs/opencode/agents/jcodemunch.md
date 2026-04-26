## MCP project tools

The project provides MCP servers usable for code and documentation. When available, use them in priority for reading, exploration, and analysis tasks.

### `jcodemunch`

Use in priority for:

- exploring repository structure
- retrieving symbols, references, importers and blast radius
- preparing refactors or impact analysis
- fetching only relevant code context instead of full files

### `jdocmunch`

Use in priority for:

- retrieving documentation in `docs/`
- checking if something is already documented
- identifying sections to update after changes
- keeping documentation consistent with code

### Practical rule

Before any significant refactor or structural change:

- query jcodemunch for code
- query jdocmunch for documentation
