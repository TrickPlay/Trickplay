--[[
Filename: Path5.lua
Author: Peter von dem Hagen
Date: November 14, 2011
Description:  Test path using path commands
--]]

-- Test Set up --



-- Testing length and get_position
local globe2 = Image ()
local path2 = Path()
globe2.src = "packages/engine_unit_tests/tests/assets/globe.png"
globe2.scale = {0.1, 0.1}
globe2.position = {0, 0}
test_group:add(globe2)


path2:add_string_path ("m 200,200 l 1400,200 c 1675,200  610,400 200,200 z")


local lastGetPosition = {}
local timeline = Timeline
{
	duration = 500,
	loop = false,
	on_new_frame =
		function( timeline , duration , progress )
			globe2.position = path2:get_position( progress )
			lastGetPosition = path2:get_position( progress )
		end
}

timeline:start()


-- Tests --

-- Verify that curve_to finishes up at the expected location.
function test_Path_path_z ()
    assert_equal( lastGetPosition[1], 200, "Result: "..  lastGetPosition[1].." Expected: 200" )
    assert_equal( lastGetPosition[2], 200, "Result: "..  lastGetPosition[2].." Expected: 200" )
end

--]]

-- Test Tear down --













