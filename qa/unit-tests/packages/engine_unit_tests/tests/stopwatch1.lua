--[[
Filename: stopwatch1.lua
Author: Peter von dem Hagen
Date: January 26, 2011
Description:  Start the stopwatch, then stop it immediately after.
			  Verify that continue start it up again.
			  Wait the few seconds until unit tests are kicked off.
			  Verify that it return values over 2.
--]]


-- Test Set up --

local stopwatch = Stopwatch ()
stopwatch:start()
stopwatch:stop()
stopwatch:continue() 


-- Tests --

-- Stop the stopwatch when the unit tests kicks off. elapsed should be over 2 seconds.
function test_stopwatch_basic ()
	stopwatch:stop()
    assert_greater_than ( stopwatch.elapsed_seconds , 1, "stopwatch.elapsed_seconds failed" )
    assert_greater_than ( stopwatch.elapsed , 2000, "stopwatch.elapsed failed" )
end


-- Test Tear down --













