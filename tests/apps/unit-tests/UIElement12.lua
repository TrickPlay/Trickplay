--[[
Filename: UIElement12.lua
Author: Peter von dem Hagen
Date: April 19, 2011
Description:  This test verifies that UIElement objects call the on_key_focus events accordingly
--]]

-- Test Set up --
local on_key_focus_in_called = false
local on_key_focus_out_called = false

logo_image = Image()
globe_image = Image()

logo_image.src = "assets/logo.png"
logo_image.position = { 150, 120 }
screen:add(logo_image)

globe_image.src = "assets/globe.png"
globe_image.position = { 200, 200 }
screen:add(globe_image)

function logo_image.on_key_focus_in (self)
	on_key_focus_in_called = true
end

function logo_image.on_key_focus_out (self)
	on_key_focus_out_called = true
end

--[[
Note: The following code is in the main.lua as the focus was switching before the events were set up.
	logo_image:grab_key_focus()
	globe_image:grab_key_focus()
--]]

-- Tests --

function test_UIElement_on_key_focus_events ()
    assert_equal( on_key_focus_in_called , true , "on_key_focus_in not called" )
    assert_equal( on_key_focus_out_called , true , "on_key_focus_out not called" )
end


-- Test Tear down --













