--[[
Filename: Text9.lua
Author: Name
Date: October 29, 2011
Description:   Test the text manipulation functions - get_chars
--]]

local myText1 = Text ()
myText1.text = "Fun with Dick and Jane"
myText1.font = "DejaVu Sans 20px"
myText1.color = "33FF22AA"
myText1.position = { 1400, 100 }

-- Basic get of characters in a string using get_chars --
function test_Text_get_chars_basic ()
	assert_equal (myText1:get_chars( 0, 3 ), "Fun", "myText1.get_chars(0,3) returned: "..myText1:get_chars(0,3).." Expected: Fun")
end

function test_Text_get_chars_all_characters ()
	assert_equal (myText1:get_chars( 0, -1 ), "Fun with Dick and Jane", "myText1.get_chars(0,-1) returned: "..myText1:get_chars(0,3).." Expected: Fun with Dick and Jane")
end

test_group:add ( myText1)













