--[[
Filename: Rectangle1.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Create a rectangle object and verify that the setters are what they should be.
--]]

-- Test Set up --


local rect1 = Rectangle ()

rect1.color = { 153, 51, 85 }
rect1.border_width = 3
rect1.border_color = "88FFFF"
rect1.size = { 60 , 60 }
rect1.position = { 700 , 700 }

test_group:add(rect1)


-- Tests --

-- Verify the rectangle setters.
function test_Rectangle_setters ()
	assert_equal(rect1.border_width, 3 , "Result: "..rect1.border_width.." Expected: 3" )
	assert_equal(rect1.border_color[1], 136 , "Result: "..rect1.border_color[1].." Expected: 136" )
	assert_equal(rect1.border_color[2], 255 , "Result: "..rect1.border_color[2].." Expected: 255" )
	assert_equal(rect1.border_color[3], 255 , "Result: "..rect1.border_color[3].." Expected: 255" )
	assert_equal(rect1.border_color[4], 255 , "Result: "..rect1.border_color[4].." Expected: 255" )
	assert_equal(rect1.color[1],  153 , "Result: "..rect1.color[1].." Expected: 153" )
	assert_equal(rect1.color[2],  51 , "Result: "..rect1.color[2].." Expected: 51" )
	assert_equal(rect1.color[3],  85 , "Result: "..rect1.color[3].." Expected: 85" )
	assert_equal(rect1.color[4],  255 , "Result: "..rect1.color[4].." Expected: 255" )
end


-- Test Tear down --













