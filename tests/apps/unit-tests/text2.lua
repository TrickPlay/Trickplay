--[[
Filename: Text2.lua
Author: Name
Date: January 20, 2011
Description:   Make a change to the text and verify that the event handler gets called
--]]




-- Test Set up --
local myText1 = Text ()
local textChanged = false

myText1.text = "Any no app like a Trickplay app..."
myText1.font = "DejaVu Sans 20px"
myText1.color = "FFFFFFAA"
myText1.position = { 1000, 10 }

function text_changed (text)
	textChanged = true
end	

myText1.on_text_changed = text_changed

screen:add(myText1)
screen:show()

-- Tests --

-- Make a change to the text and verify the event handler gets called
function test_Text_on_text_changed ()
	myText1.text = "Changed"  --change the text to invoke the event handler
	assert_equal( textChanged, true, "on_text_changed event not called")
end


-- Test Tear down --













