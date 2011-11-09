--[[
Filename: Timeline4.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:  Verify reverse starts that timeline from 0 by never letting progress get beyond 350.
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 0, 600 }
test_group:add (image1)


local myTimeline = Timeline ()
local frameCount = 0
myTimeline.duration = 200
myTimeline.loop = false

myTimeline.on_new_frame = function (self, timeline_ms, progress) 
	frameCount= frameCount + 1
	image1.x = 1000 * progress
	if progress > 0.2 and myTimeline.direction == "FORWARD" then
		myTimeline:reverse ()
	end
end

myTimeline:start()


-- Tests --

-- Verify that reverse is starting the timeline from 0 and is always less then 350.
function test_Timeline_reverse ()
    assert_less_than ( image1.x , 350,  "Returned: ", image1.x, " Expected: <350")
end


-- Test Tear down --













