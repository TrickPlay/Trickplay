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
function test_ ()
    assert_equal( (t:get_value( 0.5 )), 5 , "interval failed" )
    assert_equal( (t:get_value( 0 )), -10 , "interval failed" )
    assert_equal( (t:get_value( 1.0 )), 20 , "interval failed" )
end


-- Test Tear down --













