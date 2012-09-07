--[[
Filename: profile1.lua
Author: Peter von dem Hagen
Date: January 26, 2011
Description:  Make changes to the profile id and name then verify that the on_changed
			  and on_changing events are called
--]]


-- Test Set up --
local profile_id_changed = false
local profile_id_changing = false


-- The following 2 events cannot be tested at this time. [4/19/2011] 
profile.on_changed = function ()
	profile_id_changed = true
	--print ("profile changed")
end

profile.on_changing = function ()
	profile_id_changing = true
	--print ("profile changing")
end



-- Tests --


function test_global_profile_basic ()
	assert_equal( profile.id, 1, "profile.id returned: "..profile.id.." Expected: 1")
	assert_equal( profile.name, "TrickPlay User", "profile.name returned: "..profile.name.." Expected Trickplay User")
end


-- Test Tear down --













