--[[
Filename: Score1.lua
Author: Peter von dem Hagen
Date: October 31, 2011
Description:  Test that score basic score functionality is working
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 1000, 250 }
test_group:add (image1)

local score_loop_count = 0
local score_on_started_called = false
local score_on_completed_called = false

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

myTimeline1.on_completed = function ()
	score_loop_count = score_loop_count + 1
end

myTimeline2.on_completed = function ()
	score_loop_count = score_loop_count + 1
end

myTimeline3.on_completed = function ()
	score_loop_count = score_loop_count + 1
end


score1 = Score { loop = false }
score1:append (nil, myTimeline1)
score1:append (myTimeline1, myTimeline2)
score1:append (myTimeline2, myTimeline3)

score1.on_completed = function (score)
	score_on_completed_called = true
	score1:stop()
end

score1.on_started = function (score)
	score_on_started_called = true
end

score1:start()


-- Tests --

--  Did all timelines in the score complete? --
function test_score_basic ()
    assert_equal( score_loop_count , 3 , "Score looped "..score_loop_count.." times. Expected: 3" )
end

-- Did score_on_started get called?  --
function test_score_on_started ()
    assert_true ( score_on_started_called, "score.on_started returned"..tostring(score_on_started_called)..". Expected true" )
end

-- Did score_on_completed get called?  --
function test_score_on_completed ()
    assert_true ( score_on_completed_called, "score.on_completed returned"..tostring(score_on_completed_called)..". Expected true" )
end

--  Verify score.loop returns false as expected --
function test_score_loop_false ()
    assert_false ( score1.loop , "score.loop returned "..tostring(score1.loop).."..Expected false" )
end

--   score.is_playing should return false as score.loop was set to false.
function test_score_is_playing_false ()
    assert_false ( score1.is_playing , "score.is_playing returned "..tostring(score1.is_playing)..". Expected false" )
end


-- Test Tear down --













