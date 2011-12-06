--[[
Filename: Timeline6.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:    Create 3 markers (start, middle & end). When start is hit then advance_to_marker 
				end. Verify middle is never reached.
--]]


-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 100, 300 }
test_group:add (image1)
timeline6_on_completed_called = false


local myTimeline = Timeline ()
local on_middle_marker_reached_called = false
myTimeline.duration = 3000
myTimeline.loop = false
frame_count = 0

myTimeline:add_marker ("start", 200)
myTimeline:add_marker ("middle", 1900)
myTimeline:add_marker ("end", 1990)

myTimeline.on_new_frame = function (self, timeline_ms, progress)
	frame_count = frame_count + 1
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

myTimeline.on_completed = function ()
	timeline6_on_completed_called = true
end

myTimeline:start()


-- Tests --

-- Create 3 markers (start, middle & end). When start is hit then advance_to_marker end. Verify middle is never reached.
function test_Timeline_advance_to_marker ()
    assert_false ( on_middle_marker_reached_called,  "on_middle_marker_reached_called = true" )
end

-- Test Tear down --













