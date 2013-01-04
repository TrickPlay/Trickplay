--[[
Filename: Text3.lua
Author: Name
Date: October 28, 2011
Description:   Test the text manipulation functions 
--]]

-- Create a text selection and remove it using set_selection and delete_selection  --
local myText1 = Text ()
myText1.text = "Fun with Dick and Jane"
myText1.font = "DejaVu Sans 20px"
myText1.color = "33FF22AA"
myText1.position = { 700, 100 }

local myText1_changed = false

myText1.on_text_changed = function ()
	myText1_changed = true
end

myText1:set_selection(0, 4)
myText1:delete_selection()

-- Does on_text_changed event handler get called during delete_selection
function test_Text_delete_selection_event_handler ()
	assert_true (myText1_changed, "delete_selection did not fire a text changed event.")
end

-- Basic test of set_selection and the delete_selection
function test_Text_set_selection_delete_basic ()
	assert_equal( myText1.text, "with Dick and Jane", "delete_selection did not remove the first 4 characters of the string.")
end


-- Create a text selection and remove it using set_selection and delete_selection with -1 as the 1st argument --
local myText2 = Text ()
myText2.text = "Fun with Dick and Jane"
myText2.font = "DejaVu Sans 20px"
myText2.color = "33FF22AA"
myText2.position = { 700, 130 }
myText2:set_selection(-1, 4)
myText2:delete_selection()

function test_Text_set_selection_delete_using_minus_one_as_first_argument ()
	assert_equal( myText2.text, "Fun ", "delete_selection did not remove all but the first 4 characters of the string.")
end


-- Create a text selection and remove it using set_selection and delete_selection with -1 as the 2nd argument --
local myText3 = Text ()
myText3.text = "Fun with Dick and Jane"
myText3.font = "DejaVu Sans 20px"
myText3.color = "33FF22AA"
myText3.position = { 700, 160 }
myText3:set_selection(4, -1)
local myText3_result = myText3:delete_selection()


function test_Text_set_selection_delete_using_minus_one_as_second_argument ()
	assert_equal( myText3.text, "Fun ", "delete_selection did not remove all but the first 4 characters of the string.")
end

-- Get the return value from calling delete_selection and verify it returns true --
function test_Text_set_selection_delete_returns_boolean ()
	assert_true( myText3_result, "delete_selection did not return the boolean value true when successful.")
end


-- Create a text selection and remove it using delete_text --
local myText4 = Text ()
myText4.text = "Fun with Dick and Jane"
myText4.font = "DejaVu Sans 20px"
myText4.color = "33FF22AA"
myText4.position = { 700, 190 }

local myText4_changed = false

myText4.on_text_changed = function ()
	myText4_changed = true
end

myText4:delete_text (0, 4)

-- simple text removal using delete_text
function test_Text_delete_text_basic()
	assert_equal( myText4.text, "with Dick and Jane", "delete_text did not remove the first 4 characters of the string.")
end

-- verify that the on_text_changed event handler gets called during delete_text --
function test_Text_delete_text_event_handler ()
	assert_true (myText4_changed, "insert_chars did not fire a text changed event.")
end


-- Edge case: Try to delete_text on an empty string. Should fail gracefully. --
local myText5 = Text ()
myText5.text = ""
myText5.font = "DejaVu Sans 20px"
myText5.color = "33FF22AA"
myText5.position = { 700, 220 }
myText5:delete_text (0, 4)

function test_Text_delete_text_empty_string()
	assert_equal( myText5.text, "", "This test should never fail.")
end


-- Edge case: Try to delete_text past the end of a string. Should fail gracefully. --
local myText6 = Text ()
myText6.text = "Fun with Dick and Jane"
myText6.font = "DejaVu Sans 20px"
myText6.color = "33FF22AA"
myText6.position = { 700, 250 }
myText6:delete_text (18, 30)

function test_Text_delete_text_past_end_of_strong()
	assert_equal( myText6.text, "Fun with Dick and ", "This test should never fail.")
end


test_group:add(myText1, myText2, myText3, myText4, myText5, myText6)















