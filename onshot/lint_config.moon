
{
  whitelist_globals: {
    ["./"]: {
      -- aimware libraries
      "bit",
      "callbacks",
      "client",
      "common",
      "draw",
      "engine",
      "entities",
      "file",
      "globals",
      "gui",
      "http",
      "materials",
      "network",
      "panorama",
      "input",
      "vector",
      -- globals
      "LoadScript",
      "UnloadScript",
      "GetScriptName"
      "Vector3"
    },
    ["tests/"]: {
      -- busted stuff
      "describe",
      "it",
      "setup",
      "teardown",
      "before_each",
      "after_each"
    }
  }
}
