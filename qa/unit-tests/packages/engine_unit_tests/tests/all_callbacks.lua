--[[
Filename: all_callbacks.lua
Author: Peter von dem Hagen
Date: October 28, 2011
Description:  Verify that all callbacks in this test suite fired."
--]]




-- Test Set up --



-- Tests --


function test_all_callbacks_fired ()
    assert_true( all_callbacks_fired, "All callbacks did not fire." )
end


-- Test Tear down --













