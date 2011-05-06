--[[
Filename: input_ui1.lua
Author: Peter von dem Hagen
Date: April 29, 2011
Description:  Verify that the iphone returns the correct api calls for supported functionality.
--]]


-- Test Set up --

-- Tests --
function test_controllers_ui_size ()
	assert_equal ( ui_size[1], 320,  "ui_size not returning the correct width")
	assert_equal ( ui_size[2], 435, "ui_size not returning the correct heigth")
end

function test_controllers_input_size ()
	assert_equal ( input_size[1], 320,  "input_size not returning the correct width")
	assert_equal ( input_size[2], 435, "input_size not returning the correct heigth")
end

-- Test Tear down --









