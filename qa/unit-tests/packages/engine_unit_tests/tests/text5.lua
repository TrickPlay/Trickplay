--[[
Filename: Text5.lua
Author: Name
Date: October 28, 2011
Description:   Test the text manipulation functions - selected_text
--]]

-- Set a selection area of text and verify it is returned by the selected_text api  --
local myText1 = Text ()
myText1.text = "Fun with Dick and Jane"
myText1.font = "DejaVu Sans 20px"
myText1.color = "33FF22AA"
myText1.position = { 400, 100 }
myText1.cursor_position = 0
myText1.selection_end = 9

function test_Text_selected_text_basic ()
	print ("myText1.selected_text = ", myText1.selected_text)
	assert_equal (myText1.selected_text, "Fun with ", "myText1.selected_text returned: "..myText1.selected_text..". Expected: Fun with")
end


-- Set a selection area to 0 and verify selected_text returns nil --
local myText2 = Text ()
myText2.text = "Fun with Dick and Jane"
myText2.font = "DejaVu Sans 20px"
myText2.color = "33FF22AA"
myText2.position = { 400, 130 }
myText2.cursor_position = 0
myText2.selection_end = 0

function test_Text_selected_text_nil ()
	print ("myText2.selected_text = ", myText2.selected_text)
	assert_equal (myText2.selected_text, "", "myText2.selected_text returned: "..myText2.selected_text..". Expected is nil")
end

-- Set a selection area to more than the length of the text and verify selected_text returns all characters --
local myText3 = Text ()
myText3.text = "Fun with Dick and Jane"
myText3.font = "DejaVu Sans 20px"
myText3.color = "33FF22AA"
myText3.position = { 400, 160 }
myText3.cursor_position = 0
myText3.selection_end = 100

function test_Text_selected_text_beyond_text_size ()
	print ("myText3.selected_text = ", myText3.selected_text)
	assert_equal (myText3.selected_text, "Fun with Dick and Jane", "myText3.selected_text returned: "..myText3.selected_text..". Expected: Fun with Dick and Jane")
end



test_group:add (myText1, myText2, myText3 )













