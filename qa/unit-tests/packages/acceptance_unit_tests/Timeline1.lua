--[[
Filename: Timeline1.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:  Test that basic events are being called: on_new_frame, on_completed and on_started.
			  Test there are values for elapsed and 
--]]

-- Test Set up --
local image1 = Image ()
image1.src = "packages/acceptance_unit_tests/assets/logo.png"
image1.position = { 250, 250 }
test_group:add (image1)


local myTimeline = Timeline ()
local frameCount = 0
local on_new_frame_called = false
local on_completed_called = false
local on_started_called = false
local looped = 0
myTimeline.duration = 1000
myTimeline.loop = true

myTimeline.on_new_frame = function (self, timeline_ms, progress) 
	on_new_frame_called = true
	frameCount= frameCount + 1
	looped = looped + 1
	image1.x = 1000 * progress
end

myTimeline.on_completed = function ()
	on_completed_called = true
end

myTimeline.on_started = function ()
	on_started_called = true
end

myTimeline:start()


-- Tests --

-- on_new_frame should be called
function test_Timeline_on_new_frame ()
    assert_equal( on_new_frame_called , true , "on_new_frame not called" )
end

-- verify that on_completed was completed
function test_Timeline_on_completed ()
    assert_equal( on_completed_called , true , "on_completed not called" )
end

-- verify that on_started was called
function test_Timeline_on_started ()
    assert_equal( on_started_called , true , "on_started not called" )
end

-- verify that loop set to true actually looped.
function test_Timeline_looped ()
    assert_greater_than ( looped , 2 , "on_started not called" )
end

-- verify that a value for elapsed was set
function test_Timeline_elapsed ()
	assert_greater_than ( myTimeline.elapsed, 0, "elapsed is not greater than 0 ms")
end

-- verify that a value for delta was set
function test_Timeline_delta ()
	assert_greater_than ( myTimeline.delta, 0, "delta is not greater than 0 ms")
end

-- verify that a value for progressed was set
function test_Timeline_progress ()
	assert_greater_than ( myTimeline.progress, 0, "progress is not greater than 0 ms")
end

-- verify that a value for is_playing
function test_Timeline_is_playing ()
	assert_true ( myTimeline.is_playing, true, "is_playing is not returning true")
end

-- Test Tear down --













