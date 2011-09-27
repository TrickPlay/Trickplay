--[[
Filename: UIElement8.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Complete an animation then verify whether on_completed was called
--]]

-- Not sure if this is working due to bug 651

-- Test Set up --
local image1 = Image()
local on_completed_called = false

image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.x = 400
image1.y = 400
image1.h = 100
image1.w = 100

test_group:add(image1)


function animationComplete ()
	on_completed_called = true
end

image1.on_completed = animationComplete()

image1:animate{duration=1000, loop=false, x=300, y=300,}

-- Tests --

-- Verify that on_completed was called when the animation finished.
function test_UIElement_image_on_complete ()
    assert_equal(on_completed_called, true, "on_complete not called")
end


-- Test Tear down --













