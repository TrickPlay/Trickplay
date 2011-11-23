--[[
Filename: Score3.lua
Author: Peter von dem Hagen
Date: October 31, 2011
Description:  Test that score pause is working as expected 
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 1000, 450 }
test_group:add (image1)

local score1_paused_called = false

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

myTimeline1.on_completed = function ()
	score1:pause()
end

score1.on_paused = function ()
	score1_paused_called = true
end

score1:start()

-- Tests --

-- Verify that score.is_playing returns false as it should be paused. --
function test_score_pause ()
    assert_false ( score1.is_playing , "score.is_playing returned ", score1.loop, ". Expected false" )
end

-- Verify that score.on_pause returns ture as pause was called. --
function test_score_on_pause ()
    assert_true ( score1_paused_called , "score1_paused_called ", score1_paused_called, ". Expected true" )
end




-- Test Tear down --













