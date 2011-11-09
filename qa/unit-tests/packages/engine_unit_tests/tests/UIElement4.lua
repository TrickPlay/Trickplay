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
		src = "packages/engine_unit_tests/tests/assets/logo.png",
		x = 500,
		y = 500,
		h = 150,
		w = 150
	}

test_group:add(image1)

-- Tests --

-- Verify that SET is setting the correct values.
function test_UIElement_image_set ()
    assert_equal( image1.h , 150, "image1.h returned: ", image1.h, " Expected: 150")
    assert_equal( image1.w , 150, "image1.w returned: ", image1.w, " Expected: 150")
    assert_equal( image1.x , 500, "image1.x returned: ", image1.x, " Expected: 500")
    assert_equal( image1.y , 500, "image1.y returned: ", image1.hy, " Expected: 500")
end


-- Test Tear down --













