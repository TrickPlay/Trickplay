--[[
Filename: Container3.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Description: Create a group with children. Use the clear api to remove all elements from the 
			 container.
--]]

-- Test Set up --

local g = Group
{   
	children =
	{
		Text
		{
			font = "DejaVu Sans 38px" ,
			color = "FFFFFFAA" ,
			text = "This is my text1",
			position = { 300 , 400 }
		}
		,
		Rectangle
		{
			color = "66cdaa",
			size = { 60 , 60 },
			position = { 700 , 700 }
		}
	}
}



local children = g.children
test_group:add(g)

g:clear()
local children = g.children
-- Tests --

-- Verify that container:clear removes all child elements.
function test_Container_group_clear ()
	assert_equal (#children, 0,  "container.clear failed")
end


-- Test Tear down --













