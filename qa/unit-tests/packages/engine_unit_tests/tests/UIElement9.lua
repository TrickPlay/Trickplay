--[[
Filename: UIElement9.lua
Author: Peter von dem Hagen
Date: January 26, 2012
Description: Complete an animation using stop_animation.
--]]

-- Test Set up --
local image1 = Image()

image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.x = 600
image1.y = 600
image1.h = 100
image1.w = 100

test_group:add(image1)


image1:animate{duration=6000, loop=true, x=500, y=500,}

-- Tests --

-- Verify that animation was stopped.
function test_UIElement_image_stop_animation ()
	image1:stop_animation()
	assert_false(image1.is_animating, "image1.is_animating returned: ".. tostring(image1.is_animating).. " Expected: false")
end


-- Test Tear down --













