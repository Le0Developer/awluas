
minifier = require "lib/minifier"
moonscript = require "moonscript.base"

githome = "https://github.com/le0developer/awluas/blob/master/"
rawgit = "https://raw.githubusercontent.com/Le0Developer/awluas/master/"

sha2 = require "lib/sha2"

find_script = (name) ->
    to_test = {
        -- simple scripts
        --{path: "#{name}.moon"}
        {path: "scripts/#{name}.moon", xml: "#{name}.xml", dist: {
            lua: "dist/#{name}.lua"
            min: "dist/#{name}.min.lua"
            version: "dist/#{name}.version"
        }}
        -- more complex script with own directory
        {path: "#{name}/script.moon", xml: "#{name}/gui.xml", dist: {
            lua: "#{name}/dist/script.lua"
            min: "#{name}/dist/script.min.lua"
            version: "#{name}/dist/version"
        }}
        {path: "#{name}/#{name}.moon", xml: "#{name}/#{name}.xml", dist: {
            lua: "#{name}/dist/#{name}.lua"
            min: "#{name}/dist/#{name}.min.lua"
            version: "#{name}/dist/#{name}.version"
        }}
        -- utilities/apis, not meant to be used in aimware
        {path: "util/#{name}.moon", dist: {
            lua: "util/dist/#{name}.lua"
            min: "util/dist/#{name}.min.lua"
            version: "util/dist/#{name}.version"
        }}
    }
    for location in *to_test
        if fs.exists location.path
            return location

find_test = (name) ->
    to_test = {
        {path: "scripts/#{name}_test.moon", shell: false}
        {path: "scripts/tests/#{name}.moon", shell: false}
        {path: "scripts/tests/#{name}", shell: true}
        {path: "#{name}/test.moon", shell: false}
        {path: "#{name}/tests", shell: true}
        {path: "util/#{name}_test.moon", shell: false}
        {path: "util/tests/#{name}.moon", shell: false}
        {path: "util/tests/#{name}", shell: true}
    }
    for location in *to_test
        if fs.exists location.path
            return location

ensure_path = (path) ->
    if fs.exists pathname path
        return

    parents = {}
    current = path
    while true
        current = pathname current
        if not current or fs.exists current
            break
        table.insert parents, 1, current

    for dir in *parents
        fs.makeDir dir

tasks:
    build: =>
        name = @n or @name
        print name
        if type(name) != "string"
            print style "%{red}No name specified. Use '-n' or '--name'"
            return

        location = find_script name
        if not location
            print style "%{red}Unable to find script."
            return
        
        print style "%{blue}Building #{location.path}..."
        print style "  .. %{green}Reading moonscript"

        date = os.date!
        script = readfile location.path

        print style "  .. %{green}Compiling"
        lua = moonscript.to_lua script

        -- post processor
        --- remove "__REMOVE_ME__"
        print style "  .. %{green}Post processing"
        lua = lua\gsub 'return "__REMOVE_ME__"', "" -- aimware doesn't like `return`s in certain functions, so we remove them
        --- XML
        -- not recommended, because the XML code won't get minified
        -- util/xml should be used instead
        if location.xml and lua\find'"__XML__"' and fs.exists location.xml
            lua = lua\gsub '"__XML__"', "[[#{readfile location.xml}]]"
    
        local version
        --- Version (reality just a hash)
        if lua\find'"__VERSION__"' and lua\find'"__VERSION_URL__"' and location.dist.version
            print style "  .. %{green}Versioning"
            version = sha2.sha256 lua
            lua = lua\gsub '"__VERSION__"', "[[#{version}]]"
            lua = lua\gsub '"__VERSION_URL__"', "[[#{rawgit}#{location.dist.version}]]"
            if lua\find'"__VERSION_LUA__"' -- path to the compiled lua
                lua = lua\gsub '"__VERSION_LUA__"', "[[#{rawgit}#{location.dist.lua}]]"
            if lua\find'"__VERSION_LUA_MIN__"' -- path to the compiled minified lua
                lua = lua\gsub '"__VERSION_LUA_MIN__"', "[[#{rawgit}#{location.dist.min}]]"

            print style "  ..   .. %{green}Saving version"
            ensure_path location.dist.version
            writefile location.dist.version, version
            print style "  .. %{green}Done. %{reset}Version file can be efound in '#{location.dist.version}'"

        license = readfile "LICENSE"
        lua = "--[[\n#{license}\n\nGithub: #{githome}#{location.path}\nAutomatically generated and compiled on #{date}\n]]\n" .. lua
        
        -- save the lua code
        
        print style "  .. %{green}Saving"
        ensure_path location.dist.lua -- make sure all directories exist
        writefile location.dist.lua, lua
        print style "%{green}Done. %{reset}The lua can be found in '#{location.dist.lua}'"

        print style "%{blue}Minifying..."
        -- minifying
        lua = minifier.Rebuild.MinifyString lua

        print style "  .. %{green}Saving"
        lua = "-- LICENSE: #{githome}LICENSE | Github: #{githome}#{location.path} | Automatically generated and compiled on #{date}\n" .. lua
        writefile location.dist.min, lua
        print style "%{green}Done. %{reset}The minified lua can be found in '#{location.dist.min}'"

    test: =>
        name = @n or @name
        print name
        if type(name) != "string"
            print style "%{red}No name specified. Use '-n' or '--name'"
            return

        location = find_test name
        if not location
            print style "%{red}Unable to find tests."
            return
        
        if location.shell
            sh "busted #{location.path}"
        else
            moonscript.dofile location.path -- starts busted by itself

    default: =>
        -- TODO: better help, ig?
        print style "
%{blue bold}alfons build -n/--name NAME%{reset}
    Build a script.

%{blue bold}alfons test -n/--name NAME%{reset}
    Test a script, %{bold}not all scripts have tests%{reset}.
"
