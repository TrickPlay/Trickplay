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

screen:add(rect1)

screen:show()

-- Tests --

-- Verify the rectangle setters.
function test_Rectangle_setters ()
	assert_equal(rect1.border_width, 3 , "rectangle.border_width failed")
	assert_equal(rect1.border_color[1], 136 , "rectangle.border_color failed")
	assert_equal(rect1.border_color[2], 255 , "rectangle.border_color failed")
	assert_equal(rect1.border_color[3], 255 , "rectangle.border_color failed")
	assert_equal(rect1.border_color[4], 255 , "rectangle.border_color failed")
	assert_equal(rect1.color[1],  153 , "rectangle.color failed")
	assert_equal(rect1.color[2],  51 , "rectangle.color failed")
	assert_equal(rect1.color[3],  85 , "rectangle.color failed")
	assert_equal(rect1.color[4],  255 , "rectangle.color failed")
end


-- Test Tear down --













