--[[
Filename: Interval1.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:  Verify that get_value returns the correct progress value of an interval
--]]

-- Test Set up --

local t = Interval( -10, 20 )

-- Tests --

-- verify that get_value returns the correct progress value of an interval
function test_interval_get_value ()
    assert_equal( (t:get_value( 0.5 )), 5 , "Returned: "..t:get_value (0.5 ).." Expected: 5" )
    assert_equal( (t:get_value( 0 )), -10 , "Returned: "..t:get_value (0 ).." Expected: -10" )
    assert_equal( (t:get_value( 1.0 )), 20 , "Returned: "..t:get_value (1.0 ).." Expected: 20" )
end


-- Test Tear down --













