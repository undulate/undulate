# undulate
The package manager of the future.

## Terms
- 'undulate' - The package manager
- 'und' - The base command
- 'undule' - A package

## Requirements
Undulate is going to be a large undertaking. The following requirements exist:
- Local dependencies
- Extensible build interface
- Lua 5.1, 5.2, 5.3, LuaJIT compatibility
- Expandable repository
- Support for Lua frontends like MoonScript and Callisto
- SemVer compatibility

For bonus points:
- Use existing luarocks as a legacy system

Because of this, the following modules are going to come into existence:
- Package format manager
- Build interface
- Command line frontend
- Lua API
- Repository server

## Sample Usage

### Setup a project
```bash
und init .
Name: test-package
Author: The Undulators
Version (1.0.0): 1.0.0
Description (none): A test package!
License (MIT): 
You're all done!
```

The wizard will create `undule.json` and `undulate.lua`.

### Use Undulate
```lua
-- Initializes loader, only required once
require("undulate")

-- Could be loaded from `undules/carbon`
local carbon = require("carbon")
```

### Add+Install dependencies
```bash
und install carbon lpeg
# Installs Carbon and LPeg's latest releases
```

### Add dependencies with versions
```bash
und install carbon@1.1.2
```

### Install all project dependencies
```bash
und install
```

### Install dependency globally
```bash
und install -g callisto-cli
```

### Install dependency from third-party repository
```bash
und install https://my-und-repo.com/packages/carbon
```

### Install dependency from GitHub
```bash
und install github:lua-carbon/callisto
und install github:lua-carbon/callisto@master
```

### Publish new package
```bash
und publish
```

## Technical Details
Modules install to `./undules/` in the form `NAME@VERSION`, like `carbon@1.1.2`.

The `init` command creates this directory, a small loader utility (`undulate.lua`), and a package description file (`undule.json`).

`undule.json` could look like:
```json
{
	"name": "test-package",
	"author": "The Undulators",
	"version": "1.0.0",
	"description": "A test package!",
	"license": "MIT",
	"repository": "https://github.com/undulate/undulate",
	"dependencies": {
		"carbon": "1.1.2",
		"lpeg": "0.12.0"
	},
	"platforms": {
		"love": ">=0.9.0",
		"luajit": ">=2.0"
	}
}
```
