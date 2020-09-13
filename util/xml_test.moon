
_G.arg = {}
require"busted.runner"!

xml_lib = require "dist/xml" -- you need to build XML first

assert\register "assertion", "one_of", (state, arguments) ->
    if not type(arguments[1]) == "table" or #arguments ~= 2
        return false
    
    for value in *arguments[2]
        if value == arguments[1]
            return true
            
    return false

describe "xml building", ->
    describe "name", ->
        it "xml with a string as name", ->
            xml = xml_lib.XML (E) -> E "Test"
            assert.are.equal xml, "<Test/>"
        it "xml with a number as name", ->
            assert.has_error -> xml_lib.XML (E) -> E 1, "argument #1 must be string, not number"

    describe "keyword arguments", ->
        it "xml with strings as key/value", ->
            xml = xml_lib.XML (E) -> E "Test", {test: "test"}
            assert.are.equal xml, '<Test test="test"/>'
        it "xml with a number as key", ->
            assert.has_error -> 
                xml_lib.XML (E) -> E "Test", {"test"}, 
                "XML keys must be string, not number"

        it "xml with a number as value", ->
            xml = xml_lib.XML (E) -> E "Test", {number: 1}
            assert.are.equal xml, '<Test number="1"/>'
        it "xml with a list as value", ->
            xml = xml_lib.XML (E) -> E "Test", {test: {"abc", "def"}}
            assert.are.equal xml, '<Test test=["abc", "def"]/>'

        it "xml with multiple arguments", ->
            xml = xml_lib.XML (E) -> E "Test", {testA: "test", testB: "test"}
            assert.is.one_of xml, {'<Test testA="test" testB="test"/>', '<Test testB="test" testA="test"/>'}

    describe "sub functions / elements", ->
        it "xml no sub elements", ->
            xml = xml_lib.XML (E) -> E "Test", {}, -> nil
            assert.are.equal xml, '<Test></Test>'
        it "xml sub elements", ->
            xml = xml_lib.XML (E) -> E "Test", {}, -> E "Test"
            assert.are.equal xml, '<Test><Test/></Test>'
        it "xml sub elements (16)", ->
            dept = 0
            elem = (E) ->
                dept += 1
                if dept < 16
                    E "Test_#{dept}", {}, -> elem E
            xml = xml_lib.XML (E) -> elem E
            assert.are.equal xml, '<Test_1><Test_2><Test_3><Test_4><Test_5><Test_6><Test_7><Test_8><Test_9><Test_10><Test_11><Test_12><Test_13><Test_14><Test_15></Test_15></Test_14></Test_13></Test_12></Test_11></Test_10></Test_9></Test_8></Test_7></Test_6></Test_5></Test_4></Test_3></Test_2></Test_1>'

