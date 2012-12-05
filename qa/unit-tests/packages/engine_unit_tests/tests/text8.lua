--[[
Filename: Text8.lua
Author: Name
Date: October 29, 2011
Description:   Test the text manipulation functions - position_to_coordinates
--]]

-- Get the position_to_coordinates values --

local myText1 = Text ()
myText1.text = "Fun with Dick and Jane"
myText1.font = "DejaVu Sans 40px"
myText1.color = "33FF22AA"
myText1.position = { 1400, 100 }
local ptc1 = myText1:position_to_coordinates(1)
local ptc2 = myText1:position_to_coordinates(50)

-- Verify that requesting position_to_coordinates returns values --
function test_Text_position_to_coordinates_basic ()
    assert_equal (ptc1[1], 21, "myText1:position_to_coordinates[1] returned :"..ptc1[1]..". Expected: 21")
    assert_equal (ptc1[2], 0, "myText1:postion_to_coordinates[2] returned :"..ptc1[2]..". Expected: 0")
    assert_true  (ptc1[3] >=46 and ptc1[3] <= 48, "myText1:position_to_coordinates[3] returned :"..ptc1[3]..". Expected: 46-48")

end

-- Requesting a call for a character out of range returns nil --
function test_Text_position_to_coordinates_out_of_range ()
    assert_nil (ptc2,  "Out of range text:position_to_coordinates argument did not return nil")

end














