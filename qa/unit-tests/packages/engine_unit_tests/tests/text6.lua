--[[
Filename: Text6.lua
Author: Name
Date: October 28, 2011
Description:   Test the text functions - property setters and getters
--]]

-- For every Text properly verify that a value can be set (if it's not read only) and returned  --
local myText1 = Text ()
myText1.text = "Fun with Dick and Jane"
myText1.font = "DejaVu Sans 20px"
myText1.color = "33FF22AA"
myText1.position = { 400, 100 }
myText1.cursor_position = 0
myText1.selection_end = 9
myText1.editable = true
myText1.wrap_mode = "CHAR"
myText1.single_line = false
myText1.wants_enter = true
myText1.max_length = 100
myText1.ellipsize = "END"
myText1.password_char = 42
myText1.justify = true
myText1.alignment = "CENTER"
myText1.selection_color = "FF0000"
myText1.cursor_visible = true
myText1.cursor_color = "00FF00"

test_group:add ( myText1 )
myText1.line_spacing = 10

function test_Text_properties_basic ()
	assert_equal (myText1.text, "Fun with Dick and Jane", "myText1.text returned: "..myText1.text..". Expected: Fun with Dick and Jane.")
	assert_equal (myText1.font, "DejaVu Sans 20px", "myText1.font returned: "..myText1.font..". Expected: DejaVu Sans 20px.")
	assert_equal (myText1.color[1], 51, "myText1.color returned: "..myText1.color[1]..". Expected: 51")
	assert_equal (myText1.position[1], 400, "myText1.position[1] returned: "..myText1.position[1]..". Expected: 400")
	assert_equal (myText1.position[2], 100, "myText1.position[2] returned: "..myText1.position[2]..". Expected: 100")
	assert_equal (myText1.cursor_position, 0, "myText1.cursor_position returned: "..myText1.cursor_position..". Expected: 0")
	assert_equal (myText1.selection_end, 9, "myText1.selection_end returned: "..myText1.selection_end..". 9")
	assert_true (myText1.editable, "myText1.editable returned: ".. tostring(myText1.editable)..". Expected: true")
	assert_equal (myText1.wrap_mode, "CHAR", "myText1.wrap_mode returned: "..myText1.wrap_mode..". Expected: CHAR")
	assert_false (myText1.single_line, "myText1.single_line returned: "..tostring(myText1.single_line)..". Expected: false.")
	assert_true (myText1.wants_enter,  "myText1.wants_enter returned: "..tostring(myText1.wants_enter)..". Expected: true")
	assert_equal (myText1.max_length, 100, "myText1.max_length returned: "..myText1.max_length..". Expected: 100")
	assert_equal (myText1.ellipsize, "END", "myText1.ellipsize returned: "..myText1.ellipsize..". Expected: END")
	assert_equal (myText1.password_char, 42, "myText1.password_char returned: ", myText1.password_char, ". Expected: 42.")
	assert_true (myText1.justify, "justify1.text returned: "..tostring(myText1.justify)..". Expected: true.")
	assert_equal (myText1.alignment, "CENTER", "myText1.alignment returned: "..myText1.alignment..". Expected: CENTER.")
	assert_equal (myText1.baseline, 19, "myText1.baseline returned: "..myText1.baseline..". Expected:10.")
	assert_equal (myText1.line_spacing, 10, "myText1.line_spacing returned: "..myText1.line_spacing..". Expected: 10.")
	assert_equal (myText1.selection_color[1],255 , "myText1.selection_color returned: "..myText1.selection_color[1]..". Expected: 255")
	assert_true (myText1.cursor_visible, "myText1.cursor_visible returned: "..tostring(myText1.cursor_visible)..". Expected: true.")
	assert_equal (myText1.cursor_color[2], 255, "myText1.cursor_color returned: "..myText1.cursor_color[2].."Expected: Fun with Dick and Jane.")
	
end
















