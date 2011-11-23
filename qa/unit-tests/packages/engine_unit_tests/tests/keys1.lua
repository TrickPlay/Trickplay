--[[
Filename: template.lua
Author: Peter von dem Hagen
Date: January 20, 2011
Description:  
--]]




-- Test Set up --
local right_key_pressed = false

function screen.on_key_down( screen , key )
	print ("aklsjdflkasjdfkl asdjfklasf")
		if key == keys.Right then
			right_key_pressed = true
			print ("r******************ight key pressed*****************")
		end
end


-- Tests --

function test_right_key_pressed ()
    assert_true( right_key_pressed, "right_key_pressed returned ", right_key_pressed, "." )
end


-- Test Tear down --













