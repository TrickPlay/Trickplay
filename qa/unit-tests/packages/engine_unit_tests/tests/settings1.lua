--[[
Filename: settings1.lua
Author: Peter von dem Hagen
Date: January 26, 2011
Description:  Basic test of settings where various data types are added and verified.
--]]




-- Test Set up --

settings.text_value = "This is text"
settings.number_value = 2
settings.boolean_value = true
settings.table_value = { "red", { "green", "yellow" }, "blue" }
settings.temp_value = "This will be deleted for testing"
settings["temp_value"] = nil


-- Tests --


function test_global_settings_basic ()
    assert_equal( settings["text_value"] , "This is text", "Settings text failed" )
    assert_equal( settings["number_value"] , 2, "Settings number failed" )
    assert_equal( settings["boolean_value"] , true, "Settings boolean failed" )
    assert_table( settings["table_value"] , "Settings table failed" )
    assert_equal( settings["table_value"][1], "red" , "Settings table failed" )
end

function test_global_settings_null ()
    assert_nil( settings["temp_value"] , "Removing global failed" )
end

-- Test Tear down --













