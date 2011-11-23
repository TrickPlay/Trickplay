--[[
Filename: Timeline3.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:  Verify that on_completed does not get called after timeline.stop
			  Verify that is_playing returns false after timeline.stop
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 600, 600 }
test_group:add (image1)


local myTimeline = Timeline ()
local frameCount = 0
myTimeline.duration = 1000
myTimeline.loop = true

myTimeline.on_new_frame = function (self, timeline_ms, progress) 
	frameCount= frameCount + 1
	image1.x = 1000 * progress
	
	if timeline_ms > 500 then
		myTimeline:stop()
	end
end

myTimeline:start()


-- Tests --

-- on_completed should not be called if the timeline is stopped.
function test_Timeline_stop_on_completed ()
    assert_false ( timeline3_on_completed_called ,"Returned: "..tostring(timeline3_on_completed_called).." Expected: 0")
end

-- is playing should return false when stop is called
function test_Timeline_stop ()
	assert_false ( myTimeline.is_playing, "Returned: "..tostring(myTimeline.is_playing).." Expected: false")
end

-- Test Tear down --













