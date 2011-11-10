--[[
Filename: xmlParser1.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description: Create a parse object then verify that the event handlers call for each tag. 
--]]

-- Test Set up --

local p = XMLParser(nil, true)
local values = {}
local depth = 1
local namespaceFound = false
local namespaceValue
local namespacePrefix

function p.on_start_element ( parser , tag , attributes )
	values[depth] = tag
	if attributes.x ~= nil then
	   depth = depth + 1
	   values[depth] = attributes.x
	end
	depth = depth + 1
end

function p.on_character_data ( parser , dataString )
	values[depth] = dataString
	depth = depth + 1
end

function p.on_end_element ( parser , tag , attributes )
	values[depth] = tag 
	depth = depth + 1
end

function p.on_start_namespace( parser , ns	, ns2 )
    namespaceFound = true
    namespacePrefix = ns
    namespaceValue = ns2
end

local xml = [[<?xml version="1.0" encoding="ISO-8859-1"?><!-- Edited by XMLSpy¨ --><note xmlns:h="http://www.w3.org/TR/html4/"><to x="test">Tove</to><from>Jani</from><heading>Reminder</heading><body>Don't forget me this weekend!</body></note>]]


local success = p:parse( xml, true)

-- debug - print out all the parse values in order of parsing
--for i,v in ipairs(values) do print(i,v) end

-- Tests --

function test_XMLParser_parse ()
    -- Does parse return true when it should succeeds -- 
    assert_equal( success , true , "success returned: ", success, " Expected: true")
end

function test_XMLParser_onStartElements()
    assert_equal( values[1] , "note", "values[1] returned: "..values[1].." Expected: note")
    assert_equal( values[2] , "to",  "values[2] returned: "..values[2].." Expected: to")
    assert_equal( values[6] , "from",  "values[6] returned: "..values[6].." Expected: from")
    assert_equal( values[9] , "heading",  "values[9] returned: "..values[9].." Expected: heading")
    assert_equal( values[12] , "body",  "values[12] returned: "..values[12].." Expected: body")
end

function test_XMLParser_onEndElements()
    assert_equal( values[15] , "note",  "values[15] returned: "..values[15].." Expected: note")
    assert_equal( values[14] , "body", "values[14] returned: "..values[14].." Expected: body")
    assert_equal( values[11] , "heading", "values[11] returned: "..values[11].." Expected: heading")
    assert_equal( values[8] , "from", "values[8] returned: "..values[8].." Expected: from")
    assert_equal( values[5] , "to", "values[5] returned: "..values[5].." Expected: to")
end

function test_XMLParser_onStartElementsAttributes()
    assert_equal( values[3] , "test", "values[3] returned: "..values[3].." Expected: test")
end

function test_XMLParser_namespaceFound()
    assert_true ( namespaceFound, "namespaceFound returned: ", namespaceFound, " Expected: true")
   	assert_equal( namespaceValue, "http://www.w3.org/TR/html4/", "namespaceValue returned: "..namespaceValue.." Expected: http://www.w3.org/TR/html4/" )
    assert_equal( namespacePrefix, "h", "namespacePrefix returned: "..namespacePrefix.." Expected: h")
end

 













