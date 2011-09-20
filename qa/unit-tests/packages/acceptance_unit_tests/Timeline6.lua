--[[
Filename: Timeline6.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:    Create 3 markers (start, middle & end). When start is hit then advance_to_marker 
				end. Verify middle is never reached.
--]]


-- Test Set up --
local image1 = Image ()
image1.src = "packages/acceptance_unit_tests/assets/logo.png"
image1.position = { 100, 300 }
test_group:add (image1)


local myTimeline = Timeline ()
local on_middle_marker_reached_called = false
myTimeline.duration = 1000
myTimeline.loop = true

myTimeline:add_marker ("start", 100)
myTimeline:add_marker ("middle", 500)
myTimeline:add_marker ("end", 999)

myTimeline.on_new_frame = function (self, timeline_ms, progress)
	image1.x = 1000 * progress
end

myTimeline.on_marker_reached = function (timeline, name, msecs)
	if name == "start" then
		myTimeline:advance_to_marker("end")
	end
	if name == "middle" then
		on_middle_marker_reached_called = true
	end 
end

myTimeline:start()


-- Tests --

-- Create 3 markers (start, middle & end). When start is hit then advance_to_marker end. Verify middle is never reached.
function test_Timeline_advance_to_marker ()
    assert_false ( on_middle_marker_reached_called,  "on_middle_marker_reached_called = true" )
end

-- Test Tear down --













