--[[
Filename: system1.lua
Author: Peter von dem Hagen
Date: January 26, 2011
Description:  Test that certain system devices can be acquired and released.
--]]


-- Test Set up --
--[[
print (system:acquire_numeric_keypad())				-- Createdand ran test
print (system:release_numeric_keypad())				-- Likely can't be tested
print (system:acquire_transport_control_keys())		-- Need to create specific test for device
print (system:release__transport_control_keys())	-- Likely can't be tested
print (system:acquire_keyboard())					-- Create and ran test.
print (system:release_keyboard())
--]]

-- Tests --

function test_global_system_basic ()
    assert_equal( system:acquire_numeric_keypad() , true, "test failed" )
end


-- Test Tear down --













