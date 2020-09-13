--[[
MIT License

Copyright (c) 2020 LeoDeveloper

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Github: https://github.com/le0developer/awluas/blob/master/util/xml.moon
Automatically generated and compiled on Sun Sep 13 11:36:56 2020
]]
local XML
XML = function(f)
  local body = { }
  local last_body = 1
  local A
  A = function(...)
    local _list_0 = {
      ...
    }
    for _index_0 = 1, #_list_0 do
      local s = _list_0[_index_0]
      body[last_body] = s
      last_body = last_body + 1
    end
  end
  local E
  E = function(name, keyword_arguments, sub)
    assert(type(name) == "string", "argument #1 must be string, not " .. tostring(type(name)))
    assert(keyword_arguments == nil or type(keyword_arguments) == "table", "argument #2 must be nil or table, not " .. tostring(type(keyword_arguments)))
    assert(sub == nil or type(sub) == "function", "argument #3 must be function, not " .. tostring(child))
    A("<", name)
    if keyword_arguments then
      for key, value in pairs(keyword_arguments) do
        assert(type(key) == "string", "XML keys must be string, not " .. tostring(type(key)))
        A(" ", key, "=")
        if type(value) == "table" then
          A("[")
          for i, val in ipairs(value) do
            A(("%q"):format(tostring(val)))
            if i < #value then
              A(", ")
            end
          end
          A("]")
        else
          A(("%q"):format(tostring(value)))
        end
      end
    end
    if sub then
      A(">")
      sub()
      return A("</", name, ">")
    else
      return A("/>")
    end
  end
  f(E)
  return table.concat(body, "")
end
return {
  XML = XML
}