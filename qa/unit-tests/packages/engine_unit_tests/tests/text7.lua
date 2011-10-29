--[[
Filename: Text7.lua
Author: Name
Date: October 29, 2011
Description:   Test the text manipulation functions - insert chars
--]]

-- Insert text into the center of the string and at the end using -1 argument --
local myText1 = Text ()
myText1.text = "Fun with Dick and Jane"
myText1.font = "DejaVu Sans 20px"
myText1.color = "33FF22AA"
myText1.position = { 1400, 100 }
local myText1_changed = false

myText1.on_text_changed = function ()
	myText1_changed = true
end

myText1:insert_text(9, "Spot, ")
myText1:insert_text(-1,"!")

-- Basic insert of characters in a string using insert_chars --
function test_Text_insert_chars_basic ()
	assert_equal (myText1.text, "Fun with Spot, Dick and Jane!", "insert_text did not insert text as expected.")
end

-- verify that the on_text_changed event handler gets called during insert_chars --
function test_Text_insert_chars_event_handler ()
	assert_true (myText1_changed, "insert_chars did not fire a text changed event.")
end

-- Edge case - Insert text at the end using a number larger than the length of the string and a negative number  --
local myText2 = Text ()
myText2.text = "Fun with Dick and Jane"
myText2.font = "DejaVu Sans 20px"
myText2.color = "33FF22AA"
myText2.position = { 1400, 130 }
myText2:insert_text(60, "Spot")
myText2:insert_text(-4,"!")

function test_Text_insert_text_before_start_of_text ()
	assert_equal (myText2.text, "Fun with Dick and JaneSpot!", "insert_text did not insert text as expected.")
end

test_group:add ( myText1, myText2 )













