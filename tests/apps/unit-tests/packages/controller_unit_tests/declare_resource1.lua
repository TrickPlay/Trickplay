--[[
Filename: input_ui1.lua
Author: Peter von dem Hagen
Date: April 29, 2011
Description:  Verify that the iphone returns the correct api calls for supported functionality.
--]]


-- Test Set up --

-- Tests --

function test_controllers_declare_resource_status ()
	assert_true ( declare_resource_status,  "declare_resource not returning true status")
end



-- Test Tear down --









