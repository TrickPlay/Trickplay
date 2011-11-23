--[[
Filename: global_misc1.lua
Author: Peter von dem Hagen
Date: January 25, 2011
Description:  
--]]




-- Test Set up --
-- print (time())

-- Tests --


function test_global_misc_uuid ()
    assert_string ( uuid(), "uuid returned: ", uuid(), "Expected a string." )
end


-- Test Tear down --













