--[[
Filename: clone1.lua
Author: Peter von dem Hagen
Date: January 20, 2011
Description:  Clone 4 images and 4 text objects and verify they are created.
--]]


-- Test Set up --

local g = Group ()
local count = 4
local image1 = Image()
image1.src = "assets/globe.png"
image1.name = "logo"
image1.opacity = 0
screen:add(image1)

local myText = Text()
myText.text = "Clone"
myText.color = "FFFFFF"
myText.opacity = 0
myText.position = { 400, 400 }
myText.font = "DejaVu Sans italic 30px"
screen:add(myText)


for i = 1 , count do
	local block = 
		Clone 
		{
			source = image1,
			opacity = 255,
			scale = { 0.1, 0.1 },
			position = {900 + i * 30, 900 + i * 30 }
		}
	local block2 =
		Clone
		{
		   	source = myText,
			opacity = 255,
			position = {970 + i * 30, 900 + i * 30 }
        }

    g:add( block ) 
    g:add( block2 )
end

screen:add(g)
screen:show()

local children = g.children

-- Tests --

-- Verify that the 8 elements that were cloned were added to the group g
function test_Clone_basic ()
	assert_equal(#children, 8, "clone failed")
end


-- Test Tear down --











