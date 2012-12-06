--[[
Filename: bug_814.lua
Author: Peter von dem Hagen
Date: July 24, 2011
Description:  Engine hangs when adding reciprocal groups
   			  
--]]

-- Test Set up --

	local g1=Group{}
	local g2=Group{}

    print("UNIT-TEST: WE SHOULD GET A WARNING ABOUT BADLY NESTED CONTAINERS")
	g1:add(g2)
	g2:add(g1)

	screen:add(g1)

-- Tests --

function test_bug_814 ()
	 assert_equal(true, true, "No comparison for this test. Just verify engine doesn't hang")
end


-- Test Tear down --
--	g1:remove(g2)
--	g2:remove(g1)
--	screen:remove(g1)












