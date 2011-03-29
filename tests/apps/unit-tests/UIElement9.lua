--[[
Filename: UIElement9.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Complete an animation using complete_animation.
--]]

-- Test Set up --
local image1 = Image()

image1.src = "assets/logo.png"
image1.x = 600
image1.y = 600
image1.h = 100
image1.w = 100

screen:add(image1)
screen:show()

image1:animate{duration=6000, loop=true, x=500, y=500,}

-- Tests --

-- Verify that animation was stopped.
function test_UIElement_image_complete_animation ()
	image1:complete_animation()
	assert_false(image1.is_animating, "image1.is_animating ~= false")
end


-- Test Tear down --













