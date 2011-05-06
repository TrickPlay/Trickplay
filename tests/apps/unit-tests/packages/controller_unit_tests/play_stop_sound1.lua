--[[
Filename: input_ui1.lua
Author: Peter von dem Hagen
Date: April 29, 2011
Description:  Verify that the iphone returns the correct api calls for supported functionality.
--]]


-- Test Set up --

-- Tests --
function test_controllers_play_sound ()
	assert_true ( play_sound_status,  "play_sound not returning true status")
end

function test_controllers_stop_sound ()
	assert_true ( stop_sound_status,  "stop_sound not returning true status")
end



-- Test Tear down --









