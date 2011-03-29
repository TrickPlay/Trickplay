--[[
Filename: Timeline4.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:  Verify rewind starts that timeline from 0 by never letting progress get beyond 350.
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "assets/logo.png"
image1.position = { 0, 600 }
screen:add (image1)

screen:show()

local myTimeline = Timeline ()
local on_completed_called = false
local frameCount = 0
myTimeline.duration = 2000
myTimeline.loop = true

myTimeline.on_new_frame = function (self, timeline_ms, progress) 
	frameCount= frameCount + 1
	image1.x = 1000 * progress
	if progress > 0.3 then
		myTimeline:rewind()
	end
end

myTimeline:start()


-- Tests --

-- Verify that rewind is starting the timeline from 0 and is always less then 350.
function test_Timeline_rewind ()
    assert_less_than ( image1.x , 350,  "timeline.rewind not restarting" )
end


-- Test Tear down --













