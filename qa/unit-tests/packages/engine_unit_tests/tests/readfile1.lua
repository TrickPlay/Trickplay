--[[
Filename: readfile1.lua
Author: Peter von dem Hagen
Date: January 25, 2011
Description:  Read a file using readfile and verify the text is correct.
--]]




-- Test Set up --

local readfile_string = readfile ("packages/engine_unit_tests/tests/assets/trickplay_text.txt")

-- Tests --

function test_Global_readfile_basic ()
    assert_equal( readfile_string , "Trickplay Trickplay Trickplay", "readfile failed" )
end


-- Test Tear down --













