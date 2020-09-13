{
    whitelist_globals: {
        ["./"]: {
            -- AWAIMRE GLOBALS
            --- libraries 
            "bit"
            "callbacks"
            "client"
            "common"
            "draw"
            "engine"
            "entities"
            "file"
            "globals"
            "gui"
            "http"
            "materials"
            "network"
            "panorama"
            "input"
            "vector"
            --- globals
            "LoadScript"
            "UnloadScript"
            "GetScriptName"
            "Vector3"

            -- BUSTED GLOBALS
            "describe"
            "it"
            "assert"
            "setup"
            "teardown"
            "spy"
            "randomize"
        }
        ["Alfons.moon"]: {
            -- ALFONS Enviroment
            "readfile", "writefile"
            "env"
            "wildcard", "basename", "extension", "pathname", "filename"
            "moonc", "git"
            "get", "clone"
            "sh", "cmd"
            "build"
            "tasks"
            "style" -- ansikit
            "fs" -- filekit
        }
    }
}
