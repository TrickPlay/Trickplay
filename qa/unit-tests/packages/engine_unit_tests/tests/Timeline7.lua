--[[
Filename: Timeline7.lua
Author: Peter von dem Hagen
Date: November 10, 2011
Description:  Edge cases for Timeline
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 250, 250 }
test_group:add (image1)


local myTimeline1 = Timeline ()
myTimeline1.duration = -1000000000.2
myTimeline1.loop = true

myTimeline1.on_new_frame = function (self, timeline_ms, progress) 
	image1.x = 1000 * progress
end

myTimeline1:start()


local image2 = Image ()
image2.src = "packages/engine_unit_tests/tests/assets/logo.png"
image2.position = { 1250, 1250 }
test_group:add (image2)


local myTimeline2 = Timeline ()
myTimeline2.duration = 1000
myTimeline2.delay = 100000
local myTimeline2_completed = false

myTimeline2.on_new_frame = function (self, timeline_ms, progress) 
	image2.x = 1000 * progress
end

myTimeline2.on_completed = function ()
	myTimeline2_completed = true
end

myTimeline2:start()



-- Tests --

-- Boundary test with Timline duration
function test_Timeline_edge_duration_negative_length ()
    assert_equal( myTimeline1.duration , -1000000000 , "myTimeline.duration returned: "..myTimeline1.duration.." Expected: -1000000000")
end


-- Setting delay to 100 seconds should cause myTimeline2 to not complete when unit tests run
function test_Timeline_delay ()
    assert_false ( myTimeline2_completed, "myTimeline2_on_completed returned: "..tostring(myTimeline2_completed)..". Expected: true")
end



-- Test Tear down --













