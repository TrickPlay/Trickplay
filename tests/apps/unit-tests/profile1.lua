--[[
Filename: profile1.lua
Author: Peter von dem Hagen
Date: January 26, 2011
Description:  Make changes to the profile id and name then verify that the on_changed
			  and on_changing events are called
--]]

-- Note: These tests are failing because I can't change the profile values. Need to investigate.


-- Test Set up --
local profile_id_changed = false
local profile_id_changing = false


print (profile.id)
print (profile.name)

profile.on_changed = function ()
	profile_id_changed = true
	print ("profile changed")
end

profile.on_changing = function ()
	profile_id_changing = true
	print ("profile changed")
end

profile.id = 2
profile.name = "Trickplay administrator"

print (profile.id)
print (profile.name)

-- Tests --


function test_global_profile_basic ()
	assert_equal( profile.id, 2, "profile.id not changed")
	assert_equal( profile.name, "Trickplay administrator", "profile.name not changed")
    assert_equal( profile_id_changed , true, "profile.on_changed failed" )
    assert_equal( profile_id_changing , true, "profile.on_changing failed" )
end


-- Test Tear down --













