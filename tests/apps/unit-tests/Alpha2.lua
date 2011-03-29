--[[
Filename: Alpha2.lua
Author: Peter von dem Hagen
Date: January 24, 2011
Description:  Verify that on_alpha is being called.
--]]

local image1 = Image ()
image1.src = "assets/logo.png"
image1.position = { 600, 600 }
screen:add (image1)
screen:show()

local myTimeline = Timeline ()
myTimeline.duration = 1000

local on_alpha_called = false

local alpha1 = Alpha ()
alpha1.timeline = myTimeline

alpha1.on_alpha = function (alpha, progress )
	print ("on_alpha called")
	on_alpha_called = true
end

myTimeline:start()


-- Tests --

-- verify that on_alpha is being called
function test_Alpha_mode_on_alpha ()
	assert_true ( on_alpha_called, "on_alpha not called")
end

-- Test Tear down --













