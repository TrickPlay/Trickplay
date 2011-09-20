--[[
Filename: sceen1.lua
Author: Name
Date: January 19, 2011
Description: Verifies that display_size returns the correct value. 
--]]




-- Test Set up --
local myScreen = screen.display_size

-- Tests --

function test_screen_display_size ()
    assert_equal( myScreen[1] , 960 , "display_size x failed" )
    assert_equal( myScreen[2] , 540 , "display_size y failed" )
end


-- Test Tear down --













