--[[
Filename: Text1.lua
Author: Peter von dem Hagen
Date: January 20, 2011
Description:   Verify use_markup returns correct value
--]]




-- Test Set up --

-- test with markup
local myText_markup = Text ()
myText_markup.font = "DejaVu Sans 38px"
myText_markup.color = "FFFFFFAA"
textString = "<span foreground=\"blue\" size=\"x-large\">Trickplay</span> rizzocks the <i>hizzouse</i>!" 
myText_markup.markup = string.format( "%s" , textString ) 
test_group:add(myText_markup)

-- test with no markup
local myText_no_markup = Text ()
myText_no_markup.text = "Trickplay rizzocks the hizzouse!"
test_group:add(myText_no_markup)


-- Tests --


function test_Text_use_markup ()
    assert_equal( myText_markup.use_markup , true, "myText_markup.use_markup returned: "..tostring(myText_markup.use_markup).." Expected: true")
    assert_false( myText_no_markup.use_markup , "myText_no_markup.use_markup returned: "..tostring(myText_no_markup.use_markup).." Expected: false")
end


-- Test Tear down --













