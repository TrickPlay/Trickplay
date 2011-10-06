--[[
Filename: UIElement6.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description: Verify that move_by moves the image to the expected location.
--]]

-- Test Set up --
local image1 = Image()

image1:set
	{	
		src = "packages/engine_unit_tests/tests/assets/logo.png",
		x = 500,
		y = 500,
		h = 150,
		w = 150
	}

test_group:add(image1)

image1:move_by(100,100)

-- Tests --

-- Verify that move_by moves the image to the expected location.
function test_UIElement_image_move_by ()
    assert_equal( image1.x , 600 , "image1.x failed" )
    assert_equal( image1.y , 600 , "image1.y failed" ) 
end


-- Test Tear down --













