--[[
Filename: Timeline2.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:  Verify that on_pause was called when the timeline was paused.
              Verify that timeline is going backwards by ensuring that image.x never goes below 700.		  
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "assets/logo.png"
image1.position = { 800, 400 }
screen:add (image1)

screen:show()

local myTimeline = Timeline ()
local frameCount = 0
local on_paused_called = false
myTimeline.duration = 2000
myTimeline.loop = true
myTimeline.direction = "BACKWARD"

myTimeline.on_new_frame = function (self, timeline_ms, progress) 
	frameCount= frameCount + 1
	image1.x = 1000 * progress
	
	if timeline_ms < 700 then
		myTimeline:pause()
	end
end

myTimeline.on_paused = function ()
	on_paused_called = true
end

myTimeline:start()


-- Tests --

-- verify that on_pause was called when the timeline was paused.
function test_Timeline_on_paused ()
    assert_equal( on_paused_called , true , "on_paused not called" )
end

-- verify that timeline is going backwards by ensuring that image.x never goes below 700.
function test_Timeline_Backward ()
    assert_equal( image1.x < 700 , true , "Backward failed" )
end

-- Test Tear down --













