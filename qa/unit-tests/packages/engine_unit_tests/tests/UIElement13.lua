--[[
Filename: UIElement13.lua
Author: Peter von dem Hagen
Date: April 19, 2011
Description:  This test verifies that on_key_down and on_key_up events are called.
--]]

local enter_key_press_down = false
local enter_key_press_up = false
local Return_keyval


-- Test Set up --

function screen.on_key_down (self, keyval, unicode, time)
	Return_keyval = keyval
	enter_key_press_down = true
end

function screen.on_key_up (screen, key)
	enter_key_press_up = true
end

devtools:keypress( keys.Return)


-- Tests --

function test_UIElement_on_key_up_and_down ()
    assert_equal( enter_key_press_down , true , "on_key_down for Enter key not called" )
    assert_equal( enter_key_press_up , true , "on_key_up for Enter key not called" )
    assert_equal( Return_keyval , 65293 , "enter keyval not correct" )
end


-- Test Tear down --













