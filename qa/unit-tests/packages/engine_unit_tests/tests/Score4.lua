--[[
Filename: Score4.lua
Author: Peter von dem Hagen
Date: November 1, 2011
Description:  Test that score:remove_all
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 1000, 550 }
test_group:add (image1)

local MyTimeline2_started = false

local myTimeline1 = Timeline ()
myTimeline1.duration = 200

myTimeline1.on_new_frame = function (self, timeline_ms, progress) 
	image1.x = 1000 * progress
end

local myTimeline2 = Timeline ()
myTimeline2.duration = 200

myTimeline2.on_new_frame = function (self, timeline_ms, progress) 
	image1.x = 1000 * progress
end

local score1 = Score { loop = true }
score1:append (nil, myTimeline1)
score1:append (myTimeline1, myTimeline2)


myTimeline1.on_completed = function ()
	score1:remove_all()
end

myTimeline2.on_started = function ()
	MyTimeline2_started = true
end

score1:start()

-- Tests --

-- Test that myTimeline2 never started because score:remove_all was called when Timeline1 completed --
function test_score_remove_all ()
    assert_false ( MyTimeline2_started , "myTimeline2_called returned "..tostring(myTimeline2_on_started)..". Expected false" )
end



-- Test Tear down --













