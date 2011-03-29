--[[
Filename: UIElement4.lua
Author: Peter von dem Hagen
Date: January 13, 2011
Description: Animate an image and verify that is_animating returns true.
--]]



-- Test Set up --
local image1 = Image()

image1:set ( x = 500, y = 500, h = 150, w = 150 )

screen:add(image1)
screen:show()

-- Tests --

-- Default properties of loading a simple image.
function test_UIElementImageProperties ()
    assert_equal(image1.is_animating, true, "new image1.is_animating ~= false")
end


-- Test Tear down --













