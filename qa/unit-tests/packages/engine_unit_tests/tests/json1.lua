--[[
Filename: json1.lua
Author: Peter von dem Hagen
Date: January 26, 2011
Description: Test json.parse and json.stringify by converting a table to a json object
		     and then back to a table object.
--]]




-- Test Set up --

local original_table = { "blue", { "green", "red", "yellow"}, "aqua", "purple" }

local JSON_string = json:stringify (original_table, true )

local new_table = json:parse(JSON_string)

local j = json:parse("[null]")

-- Tests --

-- Verify that a table converted to a json object and then back to a table matches the original
function test_globals_json_parse_stringify ()
    assert_equal( new_table[1] , "blue" , "json conversion failed" )
    assert_equal( new_table[2][1] , "green" , "json conversion failed" )
    assert_equal( new_table[2][2] , "red" , "json conversion failed" )
    assert_equal( new_table[2][3] , "yellow" , "json conversion failed" )
    assert_equal( new_table[3] , "aqua" , "json conversion failed" )
    assert_equal( new_table[4] , "purple" , "json conversion failed" )
end

function test_globals_jason_null ()
    assert_equal ( j[1], json.null , "json.null failed" )
end


-- Test Tear down --













