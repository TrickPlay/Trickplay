--[[
Filename: Interval1.lua
Author: Peter von dem Hagen
Date: January 21, 2011
Description:  Verify that get_value returns the correct progress value of an interval
--]]

-- Test Set up --


local t1 = Interval( 0, 10 )
local t2 = Interval( 0, -10 )

-- Tests --

-- verify that get_value returns the correct progress value of an interval
function test_interval_get_value ()
    assert_equal( (t1:get_value( 0.5 )), 5 , "Returned: "..t1:get_value (0.5 ).." Expected: 5" )
    assert_equal( (t1:get_value( 0 )), 0 , "Returned: "..t1:get_value (0 ).." Expected: 0" )
    assert_equal( (t1:get_value( 1.0 )), 10 , "Returned: "..t1:get_value (1.0 ).." Expected: 10" )
end

function test_interval_negative_tests ()
    assert_equal( (t2:get_value( -1 )), 10 , "Returned: "..t2:get_value ( -1 ).." Expected: 10" )
    assert_equal( (t2:get_value( 2.0 )), -20 , "Returned: "..t2:get_value ( 2.0 ).." Expected: -20" )
    assert_equal( (t2:get_value( -0.1 )), 1 , "Returned: "..t2:get_value ( -0.1 ).." Expected: 1" )
 	assert_equal( (t2:get_value( 0.1 )), -1 , "Returned: "..t2:get_value ( 0.1 ).." Expected: -1" )
end



-- Test Tear down --













