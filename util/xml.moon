--
-- This is an utility for dynamically creating aimware XML.
--
-- Directly useable for `gui.XML`
-- 

XML = (f) ->
    body = {}
    last_body = 1
    -- Using a table and `table.concat` is a LOT faster than concatinating strings
    -- e.g. doing `A ..= "..."` a bubch of times
    A = (...) -> 
        for s in *{...}
            body[last_body] = s
            last_body += 1 -- count by ourselves to optimize the code

    E = (name, keyword_arguments, sub) ->
        assert type(name) == "string", "argument #1 must be string, not #{type name}"
        assert keyword_arguments == nil or type(keyword_arguments) == "table", "argument #2 must be nil or table, not #{type keyword_arguments}"
        assert sub == nil or type(sub) == "function", "argument #3 must be function, not #{child}"

        A "<", name
        
        if keyword_arguments
            for key, value in pairs keyword_arguments
                assert type(key) == "string", "XML keys must be string, not #{type key}"
                A " ", key, "="
                if type(value) == "table" -- special case for tables
                    A "["
                    for i, val in ipairs value
                        A "%q"\format tostring val
                        if i < #value then A ", "
                    A "]"
                else
                    A "%q"\format tostring value
        
        if sub
            A ">"
            sub!
            A "</", name, ">"
        else
            A "/>"

    f E
    table.concat body, ""


:XML
