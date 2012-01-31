--[[
Filename: UIElement12.lua
Author: Peter von dem Hagen
Date: January 26, 2012
Description: This test animates an image over 1 minute and then calls complete_animation. So the animation should
             should be stopped right after it starts. The unit_test timer runs the unit_tests 30 seconds after 
             starting so if it is still animating then complete_animation did not work. 
--]]

-- Test Set up --
local image1 = Image()
UIElement12_completed_called = false

image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.x = 600
image1.y = 600
image1.h = 100
image1.w = 100

test_group:add(image1)

function onCompleted ()
	print ("************** Animation Completed called ****************")
	UIElement12_completed_called = true
end

image1.on_completed = onCompleted()

image1:animate{duration= 60000, loop=false, x=500, y=500}
image1:complete_animation()

-- Tests --

-- Verify that animation was stopped.
function test_UIElement_image_complete_animation ()
	assert_false(image1.is_animating, "image1.is_animating returned: ".. tostring(image1.is_animating).. " Expected: false")
end


-- Test Tear down --













