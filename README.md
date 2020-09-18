
# Aimware Luas

This repository contains my scripts for the CS:GO cheat aimware and various utilities.

[[Profile](https://aimware.net/forum/user/277153)] [[+Rep](https://aimware.net/forum/user/277153/reputation/add)]

## Building

### Building requirements

For building you need:

  - Lua 5.1 or 5.3 (5.4 might work but is not tested)
  - [Alfons](https://github.com/daelvn/alfons)
    - `luarocks install alfons`
  - [Moonscript](https://moonscript.org)
    - `luarocks install moonscript`

### How to build

1. Go with your favorite shell (bash, cmd.exe, ...) into this directory
2. Execute `alfons build -n NAME` to build the project, where NAME is the name of the lua.
3. Find the paths from the output and copy the files into your aimware directory. (sample output: `Done. The lua can be found in 'dist/onshot.lua'`)

**Examples:**
    - `alfons build -n onshot` and then `dist/onshot.lua` or `dist/onshot.min.lua`
    - `alfons build -n xml` and then include the content of `util/dist/xml.min.lua` with a `loadstring([[XML]])()` into your program

## Testing

### Testing requirements

  - Lua 5.1 or 5.3 (5.4 might work but is not tested)
  - [Alfons](https://github.com/daelvn/alfons)
    - `luarocks install alfons`
  - [Moonscript](https://moonscript.org)
    - `luarocks install moonscript`
  - [Busted](http://olivinelabs.com/busted/)
    - `luarocks install busted`

### How to test

1. Go into this directory.
1. Execute `alfons test -n NAME` to test the project.
   
> **NOTE**: Not every project has a test!

**Examples:**
    - `alfons test -n xml`

## LICENSE

Every file in this repository is licensed under MIT unless mentioned below.

If you want to include parts of this lua, you MUST include a link to this repository and/or a link to the [LICENSE](<LICENSE>) file.

### Embedding

If you want to embed a part of one of my scripts, I recommend using the minifed(`NAME.min.lua`) version, and putting the copyright line above it.

**Example**:
```lua
-- program that dynamically creates XML with the xml util

-- LICENSE: https://github.com/le0developer/awluas/blob/master/LICENSE | Github: https://github.com/le0developer/awluas/blob/master/util/xml.moon | Compiled on Thu Sep 10 18:53:37 2020
local xml = loadstring([[XML CODE]])()
```

### Exceptions:

  - [lib/minifier.lua](<lib/minifier.lua>) 
    
    The [original github](https://github.com/SquidDev-CC/Howl/tree/master/howl/lexer) is under MIT. That it was posted on pastebin was a license violation **by the dev**.
    All changes are mentioned in the comments.
