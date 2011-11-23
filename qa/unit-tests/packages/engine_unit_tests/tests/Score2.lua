--[[
Filename: Score2.lua
Author: Peter von dem Hagen
Date: October 31, 2011
Description:  Test score.loop and score.is_playing
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 1000, 350 }
test_group:add (image1)


local myTimeline1 = Timeline ()
myTimeline1.duration = 200

myTimeline1.on_new_frame = function (self, timeline_ms, progress) 
	image1.x = 1000 * progress
end

local myTimeline2 = Timeline ()
myTimeline2.duration = 200
myTimeline2:reverse()

myTimeline2.on_new_frame = function (self, timeline_ms, progress) 
	image1.x = 1000 * progress
end


local myTimeline3 = Timeline ()
myTimeline3.duration = 200

myTimeline3.on_new_frame = function (self, timeline_ms, progress) 
	image1.x = 1000 * progress
end

local score1 = Score { loop = true }
score1:append (nil, myTimeline1)
score1:append (myTimeline1, myTimeline2)
score1:append (myTimeline2, myTimeline3)


score1:start()


-- Tests --

-- score.loop returns true --
function test_score_loop_true ()
    assert_true ( score1.loop , "score.loop returned "..tostring(score1.loop), "..Expected false" )
end

-- score.is_playing returns true and loop is set to true --
function test_score_is_playing_true ()
    assert_true ( score1.is_playing , "score.is_playing returned "..tostring(score1.is_playing), "..Expected false" )
end


-- Test Tear down --













