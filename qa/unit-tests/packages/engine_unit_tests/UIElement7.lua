--[[
Filename: UIElement7.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description:  Modify an images x,y,h & w values using animate and then verify that transformed_size 
              and transformed_position return the correct values
--]]

-- This test fails because the actual screensize is 960 x 540.


-- Test Set up --
local image1 = Image()

image1.src = "packages/engine_unit_tests/assets/logo.png"
image1.h = 200
image1.w = 200
image1.x = 200
image1.y = 200

test_group:add(image1)


image1:animate{duration=1000, loop=false, x=400, y=400,h=400, w=400}


-- Tests --

-- Verify the transformed size changes after the animation completes
function test_UIElement_image_transformed_size ()
	assert_equal( math.floor(image1.transformed_size[1]), math.floor(400 * screen.display_size[1]/screen.w), "image1.transformed_size[1] failed" )
	assert_equal( math.floor(image1.transformed_size[2]), math.floor(400 * screen.display_size[2]/screen.h), "image1.transformed_size[2] failed" )
end

-- Verify the transformed position changes after the animation completes
function test_UIElement_image_transformed_position ()
	assert_equal( math.floor(image1.transformed_position[1]), math.floor(400 * screen.display_size[1]/screen.w) , "image1.transformed_position[1] failed" )
	assert_equal( math.floor(image1.transformed_position[2]), math.floor(400 * screen.display_size[2]/screen.h) , "image1.transformed_position[2] failed" )
end

-- Test Tear down --













