--[[
Filename: load_file1.lua
Author: Peter von dem Hagen
Date: January 25, 2011
Description:  Verify loadfile executes a function when called.
--]]




-- Test Set up --

on_load_executed = false

loadedFunction, cError = loadfile("load_file2.lua")

loadedFunction ()


-- Tests --


function test_Global_loadfile_basic ()
    assert_equal( on_load_executed , true, "on_load failed" )
end


-- Test Tear down --













