--[[
Filename: Timeline8.lua
Author: Peter von dem Hagen
Date: October 27, 2011
Description:  Verify rewind moves the timeline back to the beginning. 
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 0, 200 }
test_group:add (image1)


local myTimeline = Timeline ()
myTimeline.duration = 2000
myTimeline.loop = false
myTimeline:add_marker ("middle", 100)
local middle_marker_count = 0
local on_new_frame_count = 0
local rewind_loop = 0

myTimeline.on_new_frame = function (self, timeline_ms, progress) 
	on_new_frame_count = on_new_frame_count + 1
	image1.x = 1000 * progress
	if progress > 0.2 then
		myTimeline:rewind ()
		rewind_loop = rewind_loop + 1
	end

	if rewind_loop == 3 then
		timeline_8_test_completed = true
	end

end

myTimeline.on_marker_reached = function (timeline, name, msecs)
	if name == "middle" then
		middle_marker_count = middle_marker_count + 1
		if middle_marker_count == 3 then
			myTimeline:stop()
		end
	end
end


myTimeline:start()


-- Tests --

-- Verify that calling rewind several times causes a marker to be passed --

function test_Timeline_rewind ()
    assert_equal ( middle_marker_count , 3,  "middle_marker_count returned: "..middle_marker_count.." Expected: 3")
end


-- Test Tear down --


