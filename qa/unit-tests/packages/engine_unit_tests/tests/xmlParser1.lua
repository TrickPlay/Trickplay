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
    assert_equal( success , true , "parse returned false instead of true")
end

function test_XMLParser_onStartElements()
    assert_equal( values[1] , "note", "onStartElements value 1 failed" )
    assert_equal( values[2] , "to", "onStartElements value 2 failed" )
    assert_equal( values[6] , "from", "onStartElements value 6 failed" )
    assert_equal( values[9] , "heading", "onStartElements value 9 failed" )
    assert_equal( values[12] , "body", "onStartElements value 11 failed" )
end

function test_XMLParser_onEndElements()
    assert_equal( values[15] , "note", "onStartElements value 14 failed" )
    assert_equal( values[14] , "body", "onStartElements value 13 failed" )
    assert_equal( values[11] , "heading", "onStartElements value 10 failed" )
    assert_equal( values[8] , "from", "onStartElements value 7 failed" )
    assert_equal( values[5] , "to", "onStartElements value 4 failed" )
end

function test_XMLParser_onStartElementsAttributes()
    assert_equal( values[3] , "test", "onStartElements - attributes value 3 failed" )
end

function test_XMLParser_namespaceFound()
    assert_equal( namespaceFound , true , "namespace not found" )
    assert_equal( namespaceValue, "http://www.w3.org/TR/html4/" )
    assert_equal( namespacePrefix, "h" )
end

 













