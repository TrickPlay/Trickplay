--[[
Filename: UIElement3.lua
Author: Peter von dem Hagen
Date: January 18, 2011
Description: Animate an image and verify that is_animating returns true.
--]]



-- Test Set up --
local image1 = Image()

image1.src = "packages/acceptance_unit_tests/assets/logo.png"
image1.x = 200
image1.y = 200
image1.h = 100
image1.w = 100

test_group:add(image1)

image1:animate{duration=4000, loop=false, x=400, y=400, h=400, w=400, opacity=160, x_rotation=90, y_rotation=90, z_rotation=90}

-- Tests --

-- Default properties of loading a simple image.
function test_UIElement_image_is_animating ()
    assert_equal(image1.is_animating, true, "new image1.is_animating ~= false")
end


-- Test Tear down --













