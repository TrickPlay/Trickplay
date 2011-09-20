--[[
Filename: Timeline5.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:  Verify has_marker returns true if a marker is set
			  Verify has_marker returns false if no marker is set
			  Verify list_markers returns all the markers.
			  Verify on_marker_reached is called when a marker is reached.
			  Verify markers returns a list of markers.

Note: This test may fail on fast systems where test_timeline_markers runs before the "end" marker is removed.
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/acceptance_unit_tests/assets/logo.png"
image1.position = { 100, 300 }
test_group:add(image1)

local myTimeline = Timeline ()
local on_marker_reached_called = 0
myTimeline.duration = 1000
myTimeline.loop = false
myTimeline:add_marker ("start", 1)
myTimeline:add_marker ("middle", 500)
myTimeline:add_marker ("middle2", 500)
myTimeline:add_marker ("end", 999)

myTimeline.on_new_frame = function (self, timeline_ms, progress) 
	image1.x = 1000 * progress
end

myTimeline.on_marker_reached = function (timeline, name, msecs)
	on_marker_reached_called = on_marker_reached_called + 1
end

myTimeline:start()


-- Tests --

-- has_marker should return true if one was set and false if not
function test_Timeline_has_marker ()
    assert_equal ( myTimeline:has_marker("middle") , true,  "timeline.has_marker != true" )
    assert_false ( myTimeline:has_marker("xxx") , "timeline.has_marker(xxx) == true" )
end

-- add and then remove a marker. has_marker should return false
function test_Timeline_remove_marker ()
	myTimeline:remove_marker("end")
    assert_false ( myTimeline:has_marker("end"), "timeline.has_marker(end) == true" )
end

-- Create 2 markers then call list_markers and verify they exist
function test_Timeline_list_markers ()
    assert_equal ( myTimeline:list_markers(500)[1], "middle2",  "timeline:list_markers(500)[1] ~= middle2" )
    assert_equal ( myTimeline:list_markers(500)[2], "middle" , "timeline:list_markers(500)[2] ~= middle" )
end

-- Create 4 markers then verify that on_marker_reached is called for each one
function test_Timeline_on_marker_reached ()
    assert_equal ( on_marker_reached_called, 4,  "on_marker_reached_call ~= 4" )
end

-- Check that 3 markers are remaining after 4 were created and 1 was removed
function test_Timeline_markers ()
	dumptable (myTimeline.markers)
    assert_equal ( myTimeline.markers[1], "start",  "timeline.markers[2] ~= start" )
    assert_equal ( myTimeline.markers[2], "middle",  "timeline.markers[3] ~= middle" )
    assert_equal ( myTimeline.markers[3], "middle2",  "timeline.markers[4] ~= middle2" )
end

-- Test Tear down --













