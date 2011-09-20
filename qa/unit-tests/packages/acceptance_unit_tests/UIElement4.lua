--[[
Filename: UIElement4.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description: Verify that SET is setting the correct values.
--]]

-- Test Set up --
local image1 = Image()

image1:set
	{	
		src = "packages/acceptance_unit_tests/assets/logo.png",
		x = 500,
		y = 500,
		h = 150,
		w = 150
	}

test_group:add(image1)

-- Tests --

-- Verify that SET is setting the correct values.
function test_UIElement_image_set ()
    assert_equal( image1.h , 150 , "image1.h failed" )
    assert_equal( image1.w , 150 , "image1.w failed" )
    assert_equal( image1.x , 500 , "image1.x failed" )
    assert_equal( image1.y , 500 , "image1.y failed" ) 
end


-- Test Tear down --













