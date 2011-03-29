--[[
Filename: UIElement6.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: hide and show an image 4 times each and then verify that the on_hide and on_show 
event handlers were called.
--]]


-- Test Set up --
local image1 = Image()
local on_hide_called = 0
local on_show_called = 0

image1.src = "assets/logo.png"
image1.x = 200
image1.y = 200
image1.h = 100
image1.w = 100
screen:add(image1)
screen:show()

function increment_on_hide_counter ()
	on_hide_called = on_hide_called + 1
end

function increment_on_show_counter ()
	on_show_called = on_show_called + 1
end

image1.on_show = increment_on_show_counter
image1.on_hide = increment_on_hide_counter


for i=1, 8, 1 do
	if image1.is_visible then
		image1:hide()
	else
		image1:show()
	end
end

-- Tests --

-- Verify that on_hide gets called 4 times.
function test_UIElement_image_on_hide ()
    assert_equal(on_hide_called, 4, "on_hide ~= 4")
end

-- Verify that on_show gets called 4 times
function test_UIElement_image_on_show ()
    assert_equal(on_show_called, 4, "on_hide ~= 4")
end


-- Test Tear down --













