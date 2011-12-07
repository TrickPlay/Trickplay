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
local frame_count = 0
local rewind_loop = 0
local progress_track = ""

myTimeline.on_new_frame = function (self, timeline_ms, progress) 
	frame_count = frame_count + 1
	image1.x = 1000 * progress
	progress_track = progress_track..progress.." / "
	if progress > 0.4 then
		myTimeline:rewind ()
		rewind_loop = rewind_loop + 1
	end

	if rewind_loop == 4 then
		timeline_8_test_completed = true
		myTimeline:stop()
	end

end

myTimeline.on_marker_reached = function (timeline, name, msecs)
	if name == "middle" then
		middle_marker_count = middle_marker_count + 1
--		if middle_marker_count == 3 then
--			myTimeline:stop()
--		end
	end
end


myTimeline:start()


-- Tests --

-- Verify that calling rewind several times causes a marker to be passed --

function test_Timeline_rewind ()
    assert_equal ( middle_marker_count , 3,  "middle_marker_count returned: "..middle_marker_count.." Expected: 3. Frame_count: "..frame_count..". Progress: "..progress_track..". Rewind_loop: "..rewind_loop )
end


-- Test Tear down --


