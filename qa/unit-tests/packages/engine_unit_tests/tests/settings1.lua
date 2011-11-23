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
    assert_equal( settings["text_value"] , "This is text", "settings[text_value] returned: "..settings["text_value"].." Expected: This is text")
    assert_equal( settings["number_value"] , 2, "settings[number_value] returned: "..settings["number_value"].." Expected: 2")
    assert_equal( settings["boolean_value"] , true, "settings[boolean_value] returned: ", settings["boolean_value"]," Expected: true")
    assert_table( settings["table_value"] , "Settings[table_value] did not return a table." )
    assert_equal( settings["table_value"][1], "red" , "settings[table_value][1] returned: "..settings["table_value"][1].." Expected: red")
end

function test_global_settings_null ()
    assert_nil( settings["temp_value"] , "settings[temp_value] did not return nil" )
end

-- Test Tear down --













