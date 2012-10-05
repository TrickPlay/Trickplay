--[[
Filename: app1.lua
Author: Peter von dem Hagen
Date: January 24, 2011
Description:  Test the basic values of the app api.
   	      Verify that app.on_load gets called.

Note: app.on_load is called in main.lua and set as a global variable
--]]

-- Test Set up --





-- Tests --

function test_app_basic ()

-- looped through app.contents and check if AdvancedUIClasses exists --
    local found_AdvancedUIClasses = false
    for i = 1, #app.contents - 200 do
	if app.contents[i] == "AdvancedUIClasses.lua" then
		found_AdvancedUIClasses = true
	end
    end

	assert_true( found_AdvancedUIClasses, "Variable found_AdvancedUIClasses returned: "..tostring(found_AdvancedUIClasses).." Expected: true")

    assert_equal( app.id, "com.trickplay.unit-tests", "app.id returned: "..app.id.." Expected: com.trickplay.unit-tests")
    assert_equal( app.name, "Trickplay Unit Tests", "app.name returned: "..app.name.." Expected: Trickplay Unit Tests")
   	assert_equal( app.release, 1, "app.release returned: "..app.release.." Expected: 1")
    assert_equal( app.version, "1.0", "app.version returned: "..app.version.." Expected: 1.0")
    assert_equal( app.author, "Trickplay QA", "app.author returned: "..app.author.." Expected:Trickplay QA")
    assert_equal( app.copyright, "© Trickplay Inc.", "app.copyright returned: "..app.copyright.." Expected: © Trickplay Inc.")
 	assert_equal( app.description, "Unit tests for the Trickplay engine.", "app.description failed" )

 	is_nil (app.launch, "app.launch is not nil" )
 	assert_equal( appOnLoadedCalled, true, "app.on_loaded not called" )
end


-- Test Tear down --
