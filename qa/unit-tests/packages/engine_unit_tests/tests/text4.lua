--[[
Filename: Text4.lua
Author: Name
Date: October 28, 2011
Description:   Test the text manipulation functions - cursor position
--]]

-- Get default cursor position then remove 4 chars from end  --
local myText1 = Text ()
myText1.text = "Fun with Dick and Jane"
myText1.font = "DejaVu Sans 20px"
myText1.color = "33FF22AA"
myText1.position = { 1200, 100 }
local myText1_changed = false

myText1.on_text_changed = function ()
	myText1_changed = true
end

-- does not delete backwards from the end
myText1:delete_chars(4)

-- Did the on_text_changed event handler get called during delete_chars --
function test_Text_delete_chars_event_handler ()
	assert_false (myText1_changed, "delete_chars fired a text changed event.")
end

-- Basic delete chars test --
function test_Text_delete_chars_basic ()
	assert_equal (myText1.text, "Fun with Dick and Jane", "delete_chars should not remove the last 4 chars of the line.")
end

function test_Text_default_cursor_position ()
	assert_equal (myText1.cursor_position, -1, "Default cursor position is not equal to -1.")
end

-- Set cursor position and delete_chars from there --
local myText2 = Text ()
myText2.text = "Fun with Dick and Jane"
myText2.font = "DejaVu Sans 20px"
myText2.color = "33FF22AA"
myText2.position = { 1200, 130 }
myText2.cursor_position = 8
myText2:delete_chars (9)

function test_Text_delete_chars_moved_cursor_position ()
	assert_equal ( myText2.text, "Fun with Jane", "delete_chars did not remove the correct section of the line:" .. myText2.text)
end

function test_Text_change_cursor_position ()
	assert_equal ( myText2.cursor_position, -1, "myText2.cursor_position is returning "..myText2.cursor_position..". Expected return value is -1.")
end


-- Set cursor position to outside the range and verify it fails gracefully
local myText3 = Text ()
myText3.text = "Fun with Dick and Jane"
myText3.font = "DejaVu Sans 20px"
myText3.color = "33FF22AA"
myText3.position = { 1200, 160 }
myText3.cursor_position = 35

function test_Text_cursor_position_out_of_text_range ()
	assert_equal ( myText3.cursor_position, -1, "myText3.cursor_position is returning "..myText3.cursor_position..". Expected return value is -1.")
end



test_group:add (myText1, myText2, myText3 )













