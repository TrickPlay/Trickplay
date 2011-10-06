--[[
Filename: input_ui1.lua
Author: Peter von dem Hagen
Date: April 29, 2011
Description:  Verify that the iphone returns the correct api calls for supported functionality.
--]]


-- Test Set up --

-- Tests --
function test_controller_start_accelerometer ()
	assert_true ( start_accelerometer_status,  "start_accelerometer not returning true status")
end

function test_controller_stop_accelerometer ()
	assert_true ( stop_accelerometer_status,  "stop_accelerometer not returning true status")
end


-- Test Tear down --









