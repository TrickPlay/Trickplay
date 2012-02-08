--[[
Filename: serialize1.lua
Author: Peter von dem Hagen
Date: January 25, 2011
Description:  verify that the serialize apis turns various data structures into a string.
--]]

-- Test Set up --

lua_table = { "blue", "green", { "yellow", "red" } }

function serialize_function (x)
	return x
end

-- Tests --

-- verify that the serialize apis turns various data structures into a string.
function test_Global_serialize_basic ()
    is_string( serialize (lua_table), "serialize table didn't return a string." )
    is_string( serialize (serialize_function (2)), "serialize function didn't return a string. " )
    is_string( serialize (true), "serialize (true) didn't return a string." )
    
end


-- Test Tear down --













