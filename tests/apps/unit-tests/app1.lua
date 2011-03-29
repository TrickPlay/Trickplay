--[[
Filename: app1.lua
Author: Peter von dem Hagen
Date: January 24, 2011
Description:  Test the basic values of the app api. 
   			  Verify that app.on_load gets called.
--]]

-- Test Set up --

local appOnLoadedCalled = false

app.on_loaded = function ()
	appOnLoadedCalled = true
end

-- Tests --

function test_app_basic ()
    assert_equal( app.id, "com.trickplay.unit-tests", "app.id failed" )
    assert_equal( app.name, "Trickplay Unit Tests", "app.name failed" )
   	assert_equal( app.release, 1, "app.release failed" ) 
    assert_equal( app.version, "1.0", "app.version failed" )
    assert_equal( app.author, "Trickplay QA", "app.author failed" )
    assert_equal( app.copyright, "© Trickplay Inc.", "app.copyright failed" )
 	assert_equal( app.description, "Unit tests for the Trickplay engine.", "app.description failed" )
 	assert_table( app.contents, "app.contents failed" )
 	is_nil (app.launch, "app.launch is not nil" )
 	assert_equal( appOnLoadedCalled, true, "app.on_loaded not called" )
end


-- Test Tear down --













