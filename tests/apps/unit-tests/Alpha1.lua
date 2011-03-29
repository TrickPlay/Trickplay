--[[
Filename: Alpha1.lua
Author: Peter von dem Hagen
Date: January 24, 2011
Description:  Basic test of Alpha where the associated timeline progress is changed to an 
			  Alpha mode. Then the progress values are compared to a default timeline.
--]]

-- Failing because of bug 713.

-- Test Set up --

local returnedAlphaProgressValues = {}
local returnedDefaultTimelineProgressValues = {}

-- Create a timeline and store the default progress values in a table
local myTimeline = Timeline ()
myTimeline.duration = 1000

myTimeline.on_new_frame = function (self, timeline_ms, progress) 
	 table.insert( returnedDefaultTimelineProgressValues , progress )
end

local image1 = Image ()
image1.src = "assets/logo.png"
image1.position = { 200, 200 }
screen:add (image1)

-- Create a timeline and associate the progress with an alpha mode. Store the values in a table.
local myTimeline1 = Timeline ()
myTimeline1.duration = 1000

local alpha1 = Alpha ()
alpha1.mode = "EASE_IN_BOUNCE"
alpha1.timeline = myTimeline1

myTimeline1.on_new_frame = function (self, timeline_ms, progress) 
	image1.x = 1000 * progress
	 table.insert( returnedAlphaProgressValues , progress )
end

screen:show()

myTimeline:start()
myTimeline1:start()

-- Tests --

-- verify that a value for is_playing
function test_Alpha_mode_basic ()

	-- Compare the default timeline and alpha timeline progress table values
	local progressTablesMatch = true
	local i = 1
	while returnedDefaultTimelineProgressValues[i] ~= nil do
		if returnedDefaultTimelineProgressValues[i] ~= returnedAlphaProgressValues[i] then
			progressTablesMatch = false
		end
		i = i + 1
	end

	assert_false ( progressTablesMatch, "Alpha progress not different from default timeline")
end

-- Test Tear down --













