--[[
Filename: Alpha1.lua
Author: Peter von dem Hagen
Date: January 24, 2011
Description:  Two alpha modes are run and the values are compared to ensure they return different values.
--]]


-- Test Set up --

local returnedLinearAlphaValues = {}
local returnedEase_in_bounce_AlphaValues = {}
local test_result

local image1 = Image ()
image1.src = "packages/engine_unit_tests/tests/assets/logo.png"
image1.position = { 200, 200 }
test_group:add (image1)

-- Create a timeline and store the default progress values in a table
local myTimeline1 = Timeline ()
myTimeline1.duration = 3000

local alpha1 = Alpha ()
alpha1.mode = "LINEAR"  -- Set this one as Linear
alpha1.timeline = myTimeline1


local alpha2 = Alpha ()
alpha2.mode = "EASE_IN_BOUNCE"  -- Set this one as Ease_In_Bounce
alpha2.timeline = myTimeline1

myTimeline1.on_new_frame = function (self, timeline_ms, progress) 
	 image1.x = 1000 * alpha2.alpha
 	 table.insert( returnedLinearAlphaValues , alpha1.alpha )
	 table.insert( returnedEase_in_bounce_AlphaValues , alpha2.alpha )
end

function do_tables_match ()
	local alphaTablesMatch = true
	local test_compares = ""
	local i = 1
	for i = 1, #returnedLinearAlphaValues do
		if returnedLinearAlphaValues[i] ~= returnedEase_in_bounce_AlphaValues[i] then
			alphaTablesMatch = false
		end
		test_compares = test_compares.."["..i.."]:"..string.sub(returnedLinearAlphaValues[i],1, 5).."/"..string.sub(returnedEase_in_bounce_AlphaValues[i],1, 5).."  "
	end
	return test_compares
end

myTimeline1.on_completed = function ()
	alpha1_completed = true
	test_result = do_tables_match()
end

myTimeline1:start()

-- Tests --

-- verify that a value for is_playing
function test_Alpha_mode_basic ()
	assert_false ( alphaTablesMatch, "Alpha values are matching."..test_result)
end

-- Test Tear down --













