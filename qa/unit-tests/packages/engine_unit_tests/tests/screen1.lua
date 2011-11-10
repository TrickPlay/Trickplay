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
    assert_equal( myScreen[1] , 960 , "myScreen[1] returned: "..myScreen[1].." Expected: 960")
    assert_equal( myScreen[2] , 540 , "myScreen[2] returned: "..myScreen[2].."Expected: 540" )
end


-- Test Tear down --













