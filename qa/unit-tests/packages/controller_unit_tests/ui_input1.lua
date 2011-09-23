--[[
Filename: input_ui1.lua
Author: Peter von dem Hagen
Date: April 29, 2011
Description:  Verify that the iphone returns the correct api calls for supported functionality.
--]]


-- Test Set up --

-- Tests --
function test_controller_ui_size ()
	--dumptable (ui_size)
	assert_equal ( ui_size[1], 320,  "ui_size not returning the correct width.\n** Disregard if not testing on iTouch/iPhone.** \n")
	assert_equal ( ui_size[2], 435, "ui_size not returning the correct heigth.\n** Disregard if not testing on iTouch/iPhone **\n")
end

function test_controller_input_size ()
	--dumptable (input_size)
	assert_equal ( input_size[1], 320,  "input_size not returning the correct width.\n** Disregard if not testing on iTouch/iPhone. **\n")
	assert_equal ( input_size[2], 435, "input_size not returning the correct heigth.\n** Disregard if not testing on iTouch/iPhone. **\n")
end

function test_controller_id()
	assert_not_nil ( ui_id,  "id is not a strong. **\n")
end

-- Test Tear down --









