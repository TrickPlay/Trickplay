--[[
Filename: Timeline6.lua
Author: Peter von dem Hagen
Date: December 7, 2011
Description:    Create 3 markers (start, middle & end). Jump past the start marker using advance_to_marker. Verify it wasn't called and that the end marker did get called.
--]]


-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 100, 300 }
test_group:add (image1)

timeline6_on_completed_called = false
local on_start_marker_reached = false
local on_end_marker_reached = false
local frame_count = 0
local progress_value
local progress_calls = ""

local myTimeline = Timeline ()
myTimeline.duration = 2000
myTimeline.loop = false

myTimeline:add_marker ("start", 200)
myTimeline:add_marker ("middle", 1000)
myTimeline:add_marker ("end", 1900)

myTimeline.on_new_frame = function (self, timeline_ms, progress)
	frame_count = frame_count + 1
	image1.x = 1000 * progress
	progress_value = progress
end

myTimeline.on_marker_reached = function (timeline, name, msecs)
	progress_calls = progress_calls.." / Name:"..name.." @ "..progress_value
	if name == "start" then
		on_start_marker_reached = true
	end
	if name == "end" then
		on_end_marker_reached = true
	end
end

myTimeline.on_completed = function ()
	timeline6_on_completed_called = true
end

myTimeline:advance_to_marker("middle")

myTimeline:start()


-- Tests --

-- Create 3 markers (start, middle & end). Set advance_to_marker to middle and check that the start marker never gets reached and the end marker does get reached.
function test_Timeline_advance_to_marker_skip ()
    assert_false ( on_start_marker_reached,  "on_start_marker_reached = true. Frame count = "..frame_count..". progress_calls = "..progress_calls)
end

function test_Timeline_advance_to_marker_reached ()
    assert_true ( on_end_marker_reached,  "on_end_marker_reached = false. Frame count = "..frame_count..". progress_calls = "..progress_calls)
end

-- Test Tear down --













