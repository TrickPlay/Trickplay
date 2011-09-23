--[[
Filename: Alpha1.lua
Author: Peter von dem Hagen
Date: January 24, 2011
Description:  Two alpha modes are run and the values are compared to ensure they return different values.
--]]


-- Test Set up --

local returnedLinearAlphaValues = {}
local returnedEase_in_bounce_AlphaValues = {}

local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 200, 200 }
test_group:add (image1)

-- Create a timeline and store the default progress values in a table
local myTimeline1 = Timeline ()
myTimeline1.duration = 1000

local alpha1 = Alpha ()
alpha1.mode = "LINEAR"  -- Set this one as Linear
alpha1.timeline = myTimeline1

myTimeline1.on_new_frame = function (self, timeline_ms, progress) 
	 image1.x = 1000 * alpha1.alpha
	 table.insert( returnedLinearAlphaValues , alpha1.alpha )
end


local image2 = Image ()
image2.src = "packages/engine_unit_tests/tests/assets/logo.png"
image2.position = { 200, 400 }
test_group:add (image2)

-- Create a timeline and associate the progress with an alpha mode. Store the values in a table.
local myTimeline2 = Timeline ()
myTimeline2.duration = 1000

local alpha2 = Alpha ()
alpha2.mode = "EASE_IN_BOUNCE"  -- Set this one as Ease_In_Bounce
alpha2.timeline = myTimeline2

myTimeline2.on_new_frame = function (self, timeline_ms, progress) 
	 image2.x = 1000 * alpha2.alpha
	 table.insert( returnedEase_in_bounce_AlphaValues , alpha2.alpha )
end


myTimeline1:start()
myTimeline2:start()

-- Tests --

-- verify that a value for is_playing
function test_Alpha_mode_basic ()
	-- Compare all the values for both alpha modes
	local alphaTablesMatch = true
	local i = 1
	while returnedLinearAlphaValues[i] ~= nil do
		if returnedLinearAlphaValues[i] ~= returnedEase_in_bounce_AlphaValues[i] then
			alphaTablesMatch = false
		end
		i = i + 1
	end

	assert_false ( alphaTablesMatch, "Alpha values for different modes are matching")
end

-- Test Tear down --













